-- This module implements a logging system for different parts of the Neovim configuration.
--
-- A new logger can be created using the `create` function which exposes methods to log messages
-- each level. The level of each logger can be queried and updated using the `get_*` and `set_*`
-- methods.
--
-- A root logger has been created to allow accessing all the methods from the logger directly via
-- module (e.g., `require('dm.logging').info(...)`).
--
-- This module is also available via the global namespace (`dm.logging`).
local logging = {}

local utils = require 'dm.utils'

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
logging.levels = {
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

-- Configuration for a `Logger`.
---@class LoggerConfig
--
-- Write log messages to the Neovim console. The messages are truncated to fit on the space
-- available in the command-line. This is done to avoid the "Press ENTER" prompts.
-- Default: `false`
---@field use_console? boolean
--
-- Write log messages to the file.
-- Default: `true`
---@field use_file? boolean
--
-- Minimum level to log messages at. Use `logging.levels` here.
-- Default: `logging.levels.WARN`
---@field level? LoggingLevel

-- Default logger configuration.
---@type LoggerConfig
local default_config = {
  use_console = false,
  use_file = true,
  level = logging.levels.WARN,
}

-- Logging date format value, used in `os.date`. For example, '2024-04-15 09:12:00'
local log_date_format = '%F %H:%M:%S'

-- Logging level to the highlight group used for console logging.
local level_highlight_group = {
  [logging.levels.TRACE] = 'Comment',
  [logging.levels.DEBUG] = 'Comment',
  [logging.levels.INFO] = 'None',
  [logging.levels.WARN] = 'WarningMsg',
  [logging.levels.ERROR] = 'ErrorMsg',
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

-- The idea here would be to cache the file handles for the current Neovim session to avoid opening
-- and closing the file for *every* log message.
-- local file_handles = {}

-- Write the message to the log file.
---@param outfile string
---@param message string
local function file_output(outfile, message)
  vim.schedule(function()
    local file = assert(io.open(outfile, 'a'))
    file:write(message .. '\n')
    file:close()
  end)
end

-- Write the message to Neovim console.
---@param name string Logger name to be prepended to the `message`
---@param message string Log message to output
---@param highlight string Highlight group to use for the `message`
local function console_output(name, message, highlight)
  vim.schedule(function()
    -- Split the message if it contains newline characters to avoid the "Press ENTER" prompt
    local chunks = vim
      .iter(vim.split(message, '\n', { trimempty = true }))
      :map(function(line)
        return { utils.truncate_echo_message(('[%s] %s'):format(name, line)), highlight }
      end)
      :totable()
    vim.api.nvim_echo(chunks, false, {})
  end)
end

-- Create a new logger with the given config.
--
-- The `name` value is prepended to log messages (e.g., '[<name>] message') for console output and
-- used as the filename (e.g., '<name>.log').
---@param name string Name of the logger
---@param config? LoggerConfig
function logging.create(name, config)
  vim.validate { name = { name, 'string' } }
  config = vim.tbl_deep_extend('force', default_config, config or {})

  ---@diagnostic disable-next-line: param-type-mismatch stdpath('log') returns a `string`
  local outfile = vim.fs.joinpath(vim.fn.stdpath 'log', name .. '.log')

  ---@param level LoggingLevel
  ---@param message string
  ---@vararg any
  local log = function(level, message, ...)
    if level < config.level then
      return
    end

    local levelname = logging.levels[level]
    local info = debug.getinfo(3, 'Sl')

    message = ('%s [%s] .../%s:%s: %s'):format(
      os.date(log_date_format),
      levelname,
      vim.fs.basename(info.short_src),
      info.currentline,
      string.format(message, unpack(convert_to_string(...)))
    )

    if config.use_console then
      local highlight = level_highlight_group[level]
      console_output(name, message, highlight)
    end

    if config.use_file then
      file_output(outfile, message)
    end
  end

  return {
    -- Checks whether the `level` is sufficient for logging.
    ---@param level LoggingLevel
    ---@return boolean
    should_log = function(level)
      return level >= config.level
    end,

    -- Return the current logging level.
    ---@return LoggingLevel
    get_level = function()
      return config.level
    end,

    -- Return the textual representation of the current logging level.
    ---@return LoggingLevelName
    get_level_name = function()
      return logging.levels[config.level]
    end,

    -- Set the logging level of this logger.
    --
    -- It must be either an integer or a string. Use `logging.levels`.
    ---@param level LoggingLevel | LoggingLevelName
    set_level = function(level)
      vim.validate {
        level = {
          level,
          function(value)
            return logging.levels[value] ~= nil, 'Use `dm.logging.levels`'
          end,
          'one of ' .. vim.inspect(vim.tbl_keys(logging.levels)),
        },
      }
      if type(level) == 'string' then
        level = logging.levels[level]
        ---@cast level LoggingLevel
      end
      config.level = level
    end,

    -- Log `message % ...` at `TRACE` level.
    ---@param message string
    ---@param ... any
    trace = function(message, ...)
      log(logging.levels.TRACE, message, ...)
    end,

    -- Log `message % ...` at `DEBUG` level.
    ---@param message string
    ---@param ... any
    debug = function(message, ...)
      log(logging.levels.DEBUG, message, ...)
    end,

    -- Log `message % ...` at `INFO` level.
    ---@param message string
    ---@param ... any
    info = function(message, ...)
      log(logging.levels.INFO, message, ...)
    end,

    -- Log `message % ...` at `WARN` level.
    ---@param message string
    ---@param ... any
    warn = function(message, ...)
      log(logging.levels.WARN, message, ...)
    end,

    -- Log `message % ...` at `ERROR` level.
    ---@param message string
    ---@param ... any
    error = function(message, ...)
      log(logging.levels.ERROR, message, ...)
    end,
  }
end

local root_logger = logging.create 'dm'

logging.should_log = root_logger.should_log
logging.get_level = root_logger.get_level
logging.get_level_name = root_logger.get_level_name
logging.set_level = root_logger.set_level

logging.trace = root_logger.trace
logging.debug = root_logger.debug
logging.info = root_logger.info
logging.warn = root_logger.warn
logging.error = root_logger.error

return logging
