local M = {}

local uv = vim.loop
local fn = vim.fn
local api = vim.api
local utils = require("core.utils")

-- Flag to signal that the BufWrite family autocmds were triggered by Format.
-- This is done to let other commands to run for these events such as linting,
-- and to avoid this module going into an infinite loop.
---@type boolean
local format_write = false

---@class Formatter
---@field cmd string
---@field args string[]|fun(filepath: string): string[]
---@field enable fun(filepath: string): boolean?
---@field stdin boolean

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
  for _, handle in ipairs({ ... }) do
    if not handle then
      return
    end
    if not handle:is_closing() then
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
  }, self)
end

-- Run the given formatter asynchronously. If it is disabled for the
-- current buffer, step onto the next formatter.
---@param formatter Formatter
function Format:run(formatter)
  if formatter.enable(self.filepath) == false then
    self:step()
    return
  end

  local args = type(formatter.args) == "function" and formatter.args(self.filepath)
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
    error(string.format(
      "Failed to run formatter '%s': %s",
      formatter.cmd,
      pid_or_err
    ))
    return
  end

  stdout:read_start(reader(self, "current_output"))
  stderr:read_start(reader(self, "err_output"))

  if formatter.stdin then
    local input_len = #self.output
    for i, v in ipairs(self.output) do
      stdin:write(v)
      if i ~= input_len then
        stdin:write("\n")
      else
        stdin:write("\n", function()
          close_safely(stdin)
        end)
      end
    end
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

-- A helper function to bridge the gap between running multiple formatters
-- asynchronously because a simple `for` loop won't cut it.
--
-- If there are no formatters, then we're done, otherwise run the next one.
function Format:step()
  if #self.formatters == 0 then
    self:done()
    return
  end
  self:run(table.remove(self.formatters, 1))
end

-- The final callback in the formatting chain which will write the final
-- output to the current buffer only if there were any changes made.
function Format:done()
  if not self.ran_formatter or vim.deep_equal(self.input, self.output) then
    return
  end
  format_write = true
  local view = fn.winsaveview()
  api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.output)
  api.nvim_command(string.format("update %s", self.filepath))
  fn.winrestview(view)
  format_write = false
end

-- Start the formatting chain.
function Format:start()
  self:step()
end

-- Adds a new formatter for the given filetype.
---@param filetype string
---@param formatter Formatter
function M.formatter(filetype, formatter)
  vim.validate({ filetype = { filetype, "s" }, formatter = { formatter, "t" } })
  if not registered_formatters[filetype] then
    registered_formatters[filetype] = {}
  end
  -- By default, every formatter is enabled and uses stdin.
  formatter.enable = formatter.enable or function()
    return true
  end
  formatter.stdin = utils.if_nil(formatter.stdin, true)
  assert(formatter.cmd, "Formatter must define a 'cmd'")
  assert(formatter.args, "Formatter must define a 'args' table or function")
  table.insert(registered_formatters[filetype], formatter)
end

-- Run all formatters for the current buffer.
-- If there are more than one formatter for the current buffer, it cycles
-- through them asynchronously, passing the ouput of the first formatter to the
-- input of the second and so on and only at the end writes the output to the
-- buffer.
function M.format()
  if format_write then
    return
  end
  if not vim.o.modifiable then
    utils.warn("[format] Buffer is not modifiable")
    return
  end
  local formatters = registered_formatters[vim.o.filetype]
  if not formatters then
    return
  end
  Format:new(formatters):start()
end

return M