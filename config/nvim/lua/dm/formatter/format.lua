local M = {}

local uv = vim.loop
local fn = vim.fn
local api = vim.api
local validate = vim.validate
local if_nil = vim.F.if_nil

-- Flag to signal that the BufWrite family autocmds were triggered by Format.
-- This is done to let other commands to run for these events such as linting,
-- and to avoid this module going into an infinite loop.
---@type boolean
local format_write = false

---@class Formatter
---@field enable? function enable/disable formatter for current file
---@field cmd string formatter command
---@field args string[]|function formatter arguments to pass
---@field stdin boolean whether to use stdin or not
---@field use_lsp boolean use the LSP provided formatter
---@field opts table LSP formatting options

---@type table<string, Formatter[]>
local registered_formatters = {}

-- Create a temporary file with the `lines` content and return the filename.
---@param lines string[]
---@return string
local function create_temp_file(lines)
  local tempfile_name = os.tmpname()
  local file, err = io.open(tempfile_name, "w+")
  assert(not err, err)

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
  local lines = {}
  local file, err = io.open(tempfile_name, "r")
  assert(not err, err)

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
    if err then
      dm.log.fmt_error("Error while reading for %s: %s", key, err)
    elseif chunk then
      buffer = buffer .. chunk
    else
      dm.log.fmt_debug("Buffer size for %s: %s", key, #buffer)
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
---@field tempfile_name string
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
  local cmd = formatter.cmd
  local args = formatter.args
  if type(args) == "function" then
    args = args()
  end

  local stdin = formatter.stdin and uv.new_pipe() or nil
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  local opts = {
    args = args,
    stdio = { stdin, stdout, stderr },
    cwd = vim.loop.cwd(),
  }

  if not formatter.stdin then
    self.tempfile_name = create_temp_file(self.output)
    table.insert(opts.args, self.tempfile_name)
  end

  local handle, pid_or_err
  handle, pid_or_err = uv.spawn(
    cmd,
    opts,
    vim.schedule_wrap(function(code)
      close_safely(stdin, stdout, stderr, handle)
      self:on_exit(code, formatter.stdin)
    end)
  )

  if not handle then
    close_safely(stdin, stdout, stderr)
    dm.log.fmt_error("Failed to run the formatter '%s'\n%s", cmd, pid_or_err)
    return
  end

  stdout:read_start(reader(self, "current_output"))
  stderr:read_start(reader(self, "err_output"))

  if formatter.stdin then
    stdin:write(table.concat(self.output, "\n"), function(err)
      if err then
        dm.log.fmt_error("Failed to write to stdin for '%s'\n%s", cmd, err)
      end
    end)
    stdin:shutdown(function(err)
      if err then
        dm.log.fmt_error("Failed to close stdin for '%s'\n%s", cmd, err)
      end
    end)
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
    -- Make sure to remove the tempfile if we were not using stdin.
    if not stdin then
      os.remove(self.tempfile_name)
    end
    dm.log.error(self.err_output)
    return self:step()
  end
  if stdin then
    self.output = vim.split(self.current_output, "\n")
  else
    self.output = read_temp_file(self.tempfile_name)
    os.remove(self.tempfile_name)
  end
  self.ran_formatter = true
  return self:step()
end

-- Run the formatter from the LSP client.
-- This assumes that the formatting requested from a client attached to the
-- buffer has the ability to do so and there is only one client capable of
-- performing the request.
---@param formatter Formatter
function Format:lsp_run(formatter)
  vim.lsp.buf_request(
    self.bufnr,
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params(formatter.opts),
    function(err, _, result)
      if err then
        dm.log.error(err.message)
        return
      end
      if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
        return
      end
      if result then
        vim.lsp.util.apply_text_edits(result, self.bufnr)
        self:write()
      end
    end
  )
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
  if formatter.enable() ~= false then
    if formatter.use_lsp then
      return self:lsp_run(formatter)
    end
    return self:run(formatter)
  else
    return self:step()
  end
end

-- The final callback in the formatting chain which will write the final
-- output to the current buffer only if:
--   - Buffer was changed
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
  if vim.tbl_isempty(self.output) then
    dm.log.warn("Skipping, received empty output:", self.output)
  else
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.output)
    self:write()
  end
  fn.winrestview(view)
end

-- Write the formatted buffer without triggering the format autocmd again.
function Format:write()
  format_write = true
  api.nvim_command(("update %s"):format(self.filepath))
  format_write = false
end

-- Validate the formatter specification.
---@param formatter Formatter
local function validate_spec(formatter)
  if formatter.use_lsp then
    validate { opts = { formatter.opts, "t" } }
  else
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
      stdin = { formatter.stdin, "b" },
    }
  end
  validate { enable = { formatter.enable, "f" } }
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
    formatter.enable = if_nil(formatter.enable, function()
      return true
    end)
    formatter.use_lsp = if_nil(formatter.use_lsp, false)
    formatter.opts = formatter.opts or {}
    validate_spec(formatter)
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
  return Format:new(formatters):step()
end

-- For debugging purposes.
M._registered_formatters = registered_formatters

return M
