local M = {}

local uv = vim.loop
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local validate = vim.validate
local server = require "dm.formatter.server"

-- Flag to signal that the BufWrite family autocmds were triggered by Format.
-- This is done to let other commands to run for these events such as linting,
-- and to avoid this module going into an infinite loop.
---@type boolean
local format_write = false

---@class Formatter
---@field enable function? enable/disable formatter for current file
---@field use string type for formatter to run, one of 'cmd', 'lsp', 'daemon_client'
---@field cmd string formatter command
---@field args string[]|function formatter arguments to pass
---@field stdin boolean whether to use stdin or not
---@field opts table LSP formatting options
---@field headers table headers to pass for the request
---@field response_handler function response handler for server requests
---@field _state table containing the current state of the daemon server

---@type table<string, Formatter[]>
local registered_formatters = {}

-- Create a temporary file with the `lines` content and return the filename.
---@param filepath string
---@param lines string[]
---@return string
local function create_temp_file(filepath, lines)
  local tempfile_name = os.tmpname()
  tempfile_name = tempfile_name
    .. "_formatting_"
    .. fn.fnamemodify(filepath, ":t")
  local file = io.open(tempfile_name, "w+")
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:flush()
  file:close()
  return tempfile_name
end

-- Read and return the contents from the given tempfile name.
---@param tempfile_name string
---@return string[]
local function read_temp_file(tempfile_name)
  local file = io.open(tempfile_name, "r")
  if file == nil then
    return
  end
  local lines = {}
  for line in file:lines() do
    lines[#lines + 1] = line
  end
  file:close()
  return lines
end

-- Helper function to close the handles safely
-- Adopted from `plenary.job.close_safely`
local function close_safely(...)
  for _, handle in ipairs { ... } do
    if handle and not handle:is_closing() then
      handle:close()
    end
  end
end

-- Reader for stdout and stderr. After the output is buffered, it will be
-- assigned to `self[key]`
---@param self Format
---@param key string
---@return function
local function reader(self, key)
  local buffer = ""
  return function(err, chunk)
    assert(not err, err)
    if chunk then
      buffer = buffer .. chunk
    else
      self[key] = buffer:gsub("\n$", "")
    end
  end
end

---@class Format
---@field bufnr number
---@field filepath string
---@field formatters Formatter[]
---@field input string[]
---@field output string[]
---@field current_output string
---@field err_output string
---@field ran_formatter boolean
---@field changedtick number
local Format = {}
Format.__index = Format

-- Initiate the format process for the given formatters.
---@param formatters Formatter[]
---@return Format
function Format:new(formatters)
  local bufnr = api.nvim_get_current_buf()
  local filepath = api.nvim_buf_get_name(bufnr)
  local input = api.nvim_buf_get_lines(bufnr, 0, -1, false)

  return setmetatable({
    bufnr = bufnr,
    filepath = filepath,
    formatters = vim.deepcopy(formatters),
    input = input,
    output = input,
    current_output = "",
    err_output = "",
    ran_formatter = false,
    changedtick = api.nvim_buf_get_changedtick(bufnr),
  }, self)
end

-- Run the given formatter asynchronously.
---@param formatter Formatter
function Format:run(formatter)
  local args = type(formatter.args) == "function"
      and formatter.args(self.bufnr, self.filepath)
    or formatter.args
  local stdin = formatter.stdin and uv.new_pipe(false) or nil
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local opts = {
    args = args,
    stdio = { stdin, stdout, stderr },
    cwd = vim.loop.cwd(),
    detached = true,
  }

  if not formatter.stdin then
    self.tempfile_name = create_temp_file(self.filepath, self.output)
    table.insert(opts.args, self.tempfile_name)
  end

  local handle, pid_or_err
  handle, pid_or_err = uv.spawn(
    formatter.cmd,
    opts,
    vim.schedule_wrap(function(code)
      close_safely(stdin, stdout, stderr, handle)
      self:on_exit(code, formatter.stdin)
    end)
  )

  if not handle then
    close_safely(stdin, stdout, stderr)
    error(
      string.format(
        "Failed to run formatter '%s': %s",
        formatter.cmd,
        pid_or_err
      )
    )
    return
  end

  stdout:read_start(reader(self, "current_output"))
  stderr:read_start(reader(self, "err_output"))

  if formatter.stdin then
    stdin:write(table.concat(self.output, "\n"))
    stdin:shutdown()
  end
end

-- Handler for the `on_exit` callback.
--
-- This will raise an error if the exitcode is not 0, update the output from
-- the last job and step into running the next formatter.
---@param code number
---@param stdin boolean
function Format:on_exit(code, stdin)
  if code > 0 then
    if not stdin then
      os.remove(self.tempfile_name)
    end
    error(self.err_output)
  end
  if stdin then
    self.output = vim.split(self.current_output, "\n")
  else
    self.output = read_temp_file(self.tempfile_name)
    os.remove(self.tempfile_name)
  end
  self.ran_formatter = true
  self:step()
end

-- Run the formatter from the LSP client.
-- This assumes that the formatting requested from a client attached to the
-- buffer has the ability to do so and there is only one client capable of
-- performing the request.
---@param formatter Formatter
function Format:lsp_run(formatter)
  lsp.buf_request(
    self.bufnr,
    "textDocument/formatting",
    lsp.util.make_formatting_params(formatter.opts),
    function(err, _, result)
      if err then
        vim.notify("[formatter]: " .. err.message, vim.log.levels.WARN)
        return
      end
      if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
        return
      end
      if result then
        lsp.util.apply_text_edits(result, self.bufnr)
        self:write()
      end
    end
  )
end

-- Check whether the given formatter is enabled for the current buffer.
---@param formatter Formatter
---@return boolean
function Format:is_enabled(formatter)
  return formatter.enable(self.bufnr, self.filepath) ~= false
end

-- A helper function to bridge the gap between running multiple formatters
-- asynchronously because a simple `for` loop won't cut it.
--
-- If there are no formatters, then we're done, otherwise check whether the
-- formatter is enabled for the current buffer and run it, otherwise run the
-- next one.
function Format:step()
  if #self.formatters == 0 then
    return self:done()
  end
  local formatter = table.remove(self.formatters, 1)
  -- Just `f()` is not a tail call, not that it makes a difference here.
  -- This is because lua still have to discard the result of the call and then
  -- return nil. `f()` is similar to `f(); return` instead of `return f()`
  if self:is_enabled(formatter) then
    dm.case(formatter.use, {
      ["cmd"] = function()
        return self:run(formatter)
      end,
      ["lsp"] = function()
        return self:lsp_run(formatter)
      end,
      ["daemon_client"] = function()
        return server.format(self, formatter)
      end,
    })
  else
    return self:step()
  end
end

-- The final callback in the formatting chain which will write the final
-- output to the current buffer only if:
--   - Buffer was not changed
--   - One of the formatter did run
--   - Output differs from the input
function Format:done()
  if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
    return
  end
  if not self.ran_formatter or vim.deep_equal(self.input, self.output) then
    return
  end
  local view = fn.winsaveview()
  api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.output)
  self:write()
  fn.winrestview(view)
end

-- Write the formatted buffer without triggering the format autocmd again.
function Format:write()
  format_write = true
  api.nvim_command(string.format("update %s", self.filepath))
  format_write = false
end

-- Start the formatting chain.
function Format:start()
  return self:step()
end

-- Validate the 'cmd' and 'args' field for the given formatter.
---@param formatter Formatter
local function validate_cmd_and_args(formatter)
  validate {
    cmd = { formatter.cmd, "s" },
    args = {
      formatter.args,
      function(a)
        local atype = type(a)
        return atype == "table" or atype == "function"
      end,
      "a table or function",
    },
  }
end

-- Register the formatters for the given filetype.
---@param filetype string
---@param formatters Formatter|Formatter[]
function M.register(filetype, formatters)
  validate { filetype = { filetype, "s" }, formatters = { formatters, "t" } }
  formatters = vim.tbl_islist(formatters) and formatters or { formatters }
  if not registered_formatters[filetype] then
    registered_formatters[filetype] = {}
  end

  for _, formatter in ipairs(formatters) do
    -- By default, every formatter is enabled.
    formatter.enable = formatter.enable or function()
      return true
    end

    dm.case(formatter.use, {
      ["cmd"] = function()
        validate_cmd_and_args(formatter)
        validate { stdin = { formatter.stdin, "b" } }
      end,
      ["lsp"] = function()
        validate { opts = { formatter.opts, "t", true } }
        formatter.opts = formatter.opts or {}
      end,
      ["daemon_client"] = function()
        validate_cmd_and_args(formatter)
        validate { headers = { formatter.headers, "t", true } }
        formatter.headers = formatter.headers or {}
        server.register(filetype, formatter)
      end,
    })

    table.insert(registered_formatters[filetype], formatter)
  end
end

-- Run all formatters for the current buffer.
-- If there are more than one formatter for the current buffer, it cycles
-- through them asynchronously, passing the ouput of the first formatter to the
-- input of the second and so on and only at the end writes the output to the
-- buffer.
function M.format()
  if format_write or not vim.bo.modifiable then
    return
  end
  local formatters = registered_formatters[vim.bo.filetype]
  if not formatters then
    return
  end
  Format:new(formatters):start()
end

-- For debugging purposes.
M._registered_formatters = registered_formatters

return M
