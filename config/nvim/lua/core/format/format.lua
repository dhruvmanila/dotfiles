local M = {}

local fn = vim.fn
local api = vim.api
local utils = require("core.utils")
local Job = require("plenary.job")

---@class Formatter
---@field cmd string
---@field args string[]|function
---@field enable function
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

---@class Format
---@field public bufnr number
---@field public filepath string
---@field public formatters Formatter[]
---@field private _output string[]
---@field private _formatted boolean
local Format = {}
Format.__index = Format

-- Initiate the format process for the given formatters.
---@param formatters Formatter[]
---@return Format
function Format:new(formatters)
  local bufnr = api.nvim_get_current_buf()
  local filepath = api.nvim_buf_get_name(bufnr)

  return setmetatable({
    bufnr = bufnr,
    filepath = filepath,
    formatters = vim.deepcopy(formatters),
    _output = api.nvim_buf_get_lines(bufnr, 0, -1, false),
    _formatted = false,
  }, self)
end

-- Run the given formatter asynchronously. If it is disabled for the
-- current buffer, step onto the next formatter.
---@param formatter table
function Format:_run(formatter)
  if formatter.enable(self.filepath) == false then
    self:_step()
    return
  end

  local cmd = formatter.cmd
  local args = type(formatter.args) == "function" and formatter.args(self.filepath)
    or formatter.args

  local job_opts = {
    command = cmd,
    args = args,
    enable_recording = true,
    on_exit = vim.schedule_wrap(function(job, code)
      self:_on_exit(job, code, formatter.stdin)
    end),
  }

  if formatter.stdin then
    job_opts.writer = self._output
  else
    self._tempfile_name = create_temp_file(self.filepath, self._output)
    table.insert(job_opts.args, self._tempfile_name)
  end

  Job:new(job_opts):start()
end

-- Handler for the `on_exit` callback.
--
-- This will raise an error if the exitcode is not 0, update the output from
-- the last job and step into running the next formatter.
function Format:_on_exit(job, code, stdin)
  if code > 0 then
    error(job:stderr_result())
  end
  if stdin then
    self._output = job:result()
  else
    self._output = read_temp_file(self._tempfile_name)
    os.remove(self._tempfile_name)
    self._tempfile_name = nil
  end
  self._formatted = true
  self:_step()
end

-- A helper function to bridge the gap between running multiple formatters
-- asynchronously because a simple `for` loop won't cut it.
--
-- If there are no formatters, then we're done, otherwise run the next one.
function Format:_step()
  if #self.formatters == 0 then
    self:_done()
    return
  end
  self:_run(table.remove(self.formatters, 1))
end

-- The final callback in the formatting chain which will write the final
-- output to the current buffer.
function Format:_done()
  if not self._formatted then
    return
  end
  local view = fn.winsaveview()
  api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self._output)
  fn.winrestview(view)
  api.nvim_command("noautocmd update")
end

-- Start the formatting chain.
function Format:start()
  self:_step()
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
