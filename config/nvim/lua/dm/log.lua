-- This module implements a logging system for different parts of the Neovim configuration.
--
-- Use the `get_logger` function to create a new logger or get an existing logger with the same
-- name. The `Logger` has methods to log messages at different level. The level of each logger can
-- be queried and updated using the `get_*` and `set_*` methods.
--
-- A root logger has been created to allow accessing all the methods from the logger directly via
-- module (e.g., `require('dm.log').info(...)`).
--
-- This module is also available via the global namespace (`dm.log`).
local M = {}

---@alias LoggingLevel
---| 0 Trace logging level
---| 1 Debug logging level
---| 2 Info logging level
---| 3 Warn logging level
---| 4 Error logging level

---@alias LoggingLevelName 'TRACE'|'DEBUG'|'INFO'|'WARN'|'ERROR'

-- Log level dictionary with reverse lookup as well.
--
-- This table can be used to lookup the number from the name or the name from the number.
-- Levels by name: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
-- Level numbers begin with "TRACE" at 0
M.levels = {
  TRACE = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  -- Add a reverse lookup.
  [0] = 'TRACE',
  [1] = 'DEBUG',
  [2] = 'INFO',
  [3] = 'WARN',
  [4] = 'ERROR',
}

-- Logging date format value, used in `os.date`. For example, '2024-04-15 09:12:00'
local log_date_format = '%F %H:%M:%S'

-- Logging level to the highlight group used for console logging.
local level_highlight_group = {
  [M.levels.TRACE] = 'Comment',
  [M.levels.DEBUG] = 'Comment',
  [M.levels.INFO] = 'None',
  [M.levels.WARN] = 'WarningMsg',
  [M.levels.ERROR] = 'ErrorMsg',
}

-- Return `number` rounded to `ndigits` precision after the decimal point.
---@param number number
---@param ndigits integer
---@return number
local function round(number, ndigits)
  local precision = 1 / math.pow(10, ndigits)
  number = number / precision
  return (number > 0 and math.floor(number + 0.5) or math.ceil(number - 0.5)) * precision
end

-- Convert the given variable number arguments to a string.
--
-- Each argument goes through the following transformations as per the type:
-- - Number is rounded off to 2 digits of precision after the decimal point
-- - Table is transformed using `vim.inspect`
--
-- Other type of arguments that are not mentioned in the above list are converted to a string
-- using `tostring`.
---@vararg any
---@return string[]
local function convert_to_string(...)
  local result = {}
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    if type(item) == 'number' then
      item = tostring(round(item, 2))
    elseif type(item) == 'table' then
      item = vim.inspect(item)
    else
      item = tostring(item)
    end
    result[#result + 1] = item
  end
  return result
end

---@type table<string, file*>
local file_handles = {}

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('dm__log_cleanup', { clear = true }),
  callback = function()
    for _, file in pairs(file_handles) do
      file:close()
    end
    file_handles = {}
  end,
  desc = 'Close all the log files before exiting',
})

-- Opens a log file at the given path and caches the file handle. All the subsequent calls for the
-- same filepath will return the same open handle.
---@param filepath string
---@return file*? #File handle
local function open_logfile(filepath)
  if file_handles[filepath] == nil then
    local logfile, err = io.open(filepath, 'a+')
    if logfile == nil then
      dm.notify_once(
        'Logging',
        { 'Failed to open log file at ' .. filepath, '', '', err },
        vim.log.levels.ERROR
      )
      return nil
    end
    file_handles[filepath] = logfile
  end
  return file_handles[filepath]
end

-- Write the message to the log file.
---@param outfile string
---@param message string
local function file_output(outfile, message)
  vim.schedule(function()
    local file = open_logfile(outfile)
    if file == nil then
      return
    end
    file:write(vim.trim(message) .. '\n')
    file:flush()
  end)
end

-- Write the message to Neovim console.
---@param name string Logger name to be prepended to the `message`
---@param message string Log message to output
---@param highlight string Highlight group to use for the `message`
local function console_output(name, message, highlight)
  -- Why use `echomsg` instead of `nvim_echo`?
  --
  -- Well, `echomsg` uses the `v:echospace` variable to truncate the message in the command-line
  -- but keep it intact when you look in the message history. For `nvim_echo`, even if we use the
  -- variable, the message history will also have the truncated message.
  vim.schedule(function()
    vim.cmd.echohl(highlight)
    local lines = vim.split(message, '\n', { trimempty = true })
    -- The surrounding quotes are required for `echomsg` as the argument is considered to be
    -- an expression. So, we need to pass in a string. Thus, we also need to escape the quotes
    -- and any backslash characters in the message.
    vim.cmd.echomsg(
      ('"[%s] %s (refer to \'%s.log\' for full message)"'):format(
        name,
        vim.fn.escape(lines[1], [["\]]),
        name
      )
    )
    vim.cmd.echohl 'NONE'
  end)
end

-- Create a new logger.
--
-- The default log level is `WARN` and the log file is created in the `stdpath('log')` directory
-- with the name `<name>.log`.
---@param name string Name of the logger
---@return Logger
local function create_logger(name)
  ---@type LoggingLevel
  local log_level = M.levels.WARN

  ---@diagnostic disable-next-line: param-type-mismatch stdpath('log') always returns a `string`
  local outfile = vim.fs.joinpath(vim.fn.stdpath 'log', name .. '.log')

  ---@param level LoggingLevel
  ---@param message string
  ---@vararg any
  local function log(level, message, ...)
    if level < log_level then
      return
    end

    local levelname = M.levels[level]

    if select('#', ...) > 0 then
      message = string.format(message, unpack(convert_to_string(...)))
    end

    message = ('%s [%s] %s'):format(os.date(log_date_format), levelname, message)

    if level >= M.levels.WARN then
      local highlight = level_highlight_group[level]
      console_output(name, message, highlight)
    end

    file_output(outfile, message)
  end

  ---@class Logger
  local logger = {}

  -- Checks whether the `level` is sufficient for logging.
  ---@param level LoggingLevel
  ---@return boolean
  function logger.should_log(level)
    return level >= log_level
  end

  -- Return the current logging level.
  ---@return LoggingLevel
  function logger.get_level()
    return log_level
  end

  -- Return the textual representation of the current logging level.
  ---@return LoggingLevelName
  function logger.get_level_name()
    return M.levels[log_level]
  end

  -- Return the filename for this logger.
  ---@return string
  function logger.get_filename()
    return outfile
  end

  -- Set the logging level of this logger.
  --
  -- It must be either an integer or a string. Use `dm.log.levels`.
  ---@param level LoggingLevel | LoggingLevelName
  function logger.set_level(level)
    vim.validate('level', level, function(value)
      return M.levels[value] ~= nil, 'Use `dm.log.levels`'
    end, 'one of ' .. vim.inspect(vim.tbl_keys(M.levels)))

    if type(level) == 'string' then
      level = M.levels[level]
      ---@cast level LoggingLevel
    end
    log_level = level
  end

  -- Log `message % ...` at `TRACE` level.
  ---@param message string
  ---@param ... any
  function logger.trace(message, ...)
    log(M.levels.TRACE, message, ...)
  end

  -- Log `message % ...` at `DEBUG` level.
  ---@param message string
  ---@param ... any
  function logger.debug(message, ...)
    log(M.levels.DEBUG, message, ...)
  end

  -- Log `message % ...` at `INFO` level.
  ---@param message string
  ---@param ... any
  function logger.info(message, ...)
    log(M.levels.INFO, message, ...)
  end

  -- Log `message % ...` at `WARN` level.
  ---@param message string
  ---@param ... any
  function logger.warn(message, ...)
    log(M.levels.WARN, message, ...)
  end

  -- Log `message % ...` at `ERROR` level.
  ---@param message string
  ---@param ... any
  function logger.error(message, ...)
    log(M.levels.ERROR, message, ...)
  end

  return logger
end

do
  ---@type table<string, Logger>
  local loggers = {}

  -- Return a logger with the given name, creating it if it doesn't exist.
  ---@param name string
  ---@return Logger
  function M.get_logger(name)
    if loggers[name] == nil then
      loggers[name] = create_logger(name)
    end
    return loggers[name]
  end
end

local root_logger = M.get_logger 'dm'

M.should_log = root_logger.should_log
M.get_level = root_logger.get_level
M.get_level_name = root_logger.get_level_name
M.set_level = root_logger.set_level

M.trace = root_logger.trace
M.debug = root_logger.debug
M.info = root_logger.info
M.warn = root_logger.warn
M.error = root_logger.error

if vim.env.NVIM_LOG_LEVEL ~= nil then
  M.set_level(vim.env.NVIM_LOG_LEVEL:upper())
end

return M
