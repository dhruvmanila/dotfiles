-- log.lua
--
-- Inspired by rxi/log.lua
-- Modified by tjdevries and can be found at github.com/tjdevries/vlog.nvim
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

-- User configuration section
---@alias LogConfig table
---@type LogConfig
local default_config = {
  -- Should print the output to neovim while running
  ---@type "'sync'"|"'async'"|"false"
  use_console = 'async',

  -- Should highlighting be used in console (using echohl)
  ---@type boolean
  highlights = true,

  -- Should write to a file
  ---@type boolean
  use_file = true,

  -- Any messages above this level will be logged.
  ---@type string|number
  level = vim.env.DEBUG and 'debug' or 'info',

  -- Level configuration
  ---@type { name: string, hl: string }[]
  modes = {
    { name = 'trace', hl = 'Comment' },
    { name = 'debug', hl = 'Comment' },
    { name = 'info', hl = 'None' },
    { name = 'warn', hl = 'WarningMsg' },
    { name = 'error', hl = 'ErrorMsg' },
    { name = 'fatal', hl = 'ErrorMsg' },
  },

  -- Limit the number of decimals displayed for floats
  ---@type number
  float_precision = 0.01,
}

local log = {}

local unpack = unpack or table.unpack

---@param config LogConfig
---@param standalone? boolean
---@return table
log.new = function(config, standalone)
  config = vim.tbl_deep_extend('force', default_config, config or {})

  local outfile = vim.fn.stdpath 'cache' .. '/dm.log'
  local obj = standalone and log or config

  local levels = {}
  for i, v in ipairs(config.modes) do
    levels[v.name] = i
  end

  -- Round a float to a certain precision.
  ---@param x number
  ---@param increment number
  ---@return number
  local function round(x, increment)
    increment = increment or 1
    x = x / increment
    return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
  end

  -- Convert the given arguments to a string.
  ---@vararg any
  ---@return string
  local function make_string(...)
    local result = {}
    for i = 1, select('#', ...) do
      local item = select(i, ...)
      if type(item) == 'number' and config.float_precision then
        item = tostring(round(item, config.float_precision))
      elseif type(item) == 'table' then
        item = vim.inspect(item)
      else
        item = tostring(item)
      end
      result[#result + 1] = item
    end
    return table.concat(result, ' ')
  end

  local console_output = vim.schedule_wrap(
    function(level_config, nameupper, msg, info)
      local lineinfo = ('%s:%s'):format(
        vim.fn.fnamemodify(info.short_src, ':t'),
        info.currentline
      )
      local console_string = ('%s [%s] .../%s: %s'):format(
        os.date '%H:%M:%S',
        nameupper,
        lineinfo,
        msg
      )

      if config.highlights and level_config.hl then
        vim.cmd('echohl ' .. level_config.hl)
      end

      local split_console = vim.split(
        console_string,
        '\n',
        { trimempty = true }
      )
      for _, v in ipairs(split_console) do
        local formatted_msg = vim.fn.escape(v, [["\]])

        local ok = pcall(vim.cmd, string.format([[echom "%s"]], formatted_msg))
        if not ok then
          vim.api.nvim_out_write(msg .. '\n')
        end
      end

      if config.highlights and level_config.hl then
        vim.cmd 'echohl NONE'
      end
    end
  )

  local file_output = vim.schedule_wrap(function(nameupper, msg, info)
    local lineinfo = ('%s:%s'):format(
      vim.fn.fnamemodify(info.short_src, ':t'),
      info.currentline
    )
    local fp = assert(io.open(outfile, 'a'))
    fp:write(
      ('%s [%s] .../%s: %s\n'):format(
        os.date '%Y/%m/%d %H:%M:%S',
        nameupper,
        lineinfo,
        msg
      )
    )
    fp:close()
  end)

  local log_at_level = function(level, level_config, message_maker, ...)
    -- Return early if we're below the config.level
    if level < levels[config.level] then
      return
    end

    local nameupper = level_config.name:upper()
    local msg = message_maker(...):gsub('\n$', '')
    local info = debug.getinfo(config.info_level or 2, 'Sl')

    -- Output to console
    if config.use_console then
      console_output(level_config, nameupper, msg, info)
    end

    -- Output to log file
    if config.use_file then
      file_output(nameupper, msg, info)
    end
  end

  for i, x in ipairs(config.modes) do
    -- log.info("these", "are", "separated")
    obj[x.name] = function(...)
      return log_at_level(i, x, make_string, ...)
    end

    -- log.fmt_info("These are %s strings", "formatted")
    obj[('fmt_%s'):format(x.name)] = function(...)
      return log_at_level(i, x, function(...)
        local passed = { ... }
        local fmt = table.remove(passed, 1)
        local inspected = {}
        for _, v in ipairs(passed) do
          table.insert(inspected, vim.inspect(v))
        end
        return string.format(fmt, unpack(inspected))
      end, ...)
    end

    -- log.lazy_info(expensive_to_calculate)
    obj[('lazy_%s'):format(x.name)] = function(f)
      return log_at_level(i, x, function()
        return f()
      end)
    end

    -- log.file_info("do not print")
    obj[('file_%s'):format(x.name)] = function(vals, override)
      local original_console = config.use_console
      config.use_console = false
      config.info_level = override.info_level
      log_at_level(i, x, make_string, unpack(vals))
      config.use_console = original_console
      config.info_level = nil
    end
  end

  return obj
end

log.new(default_config, true)

return log
