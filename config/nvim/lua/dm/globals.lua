-- Custom global namespace.
_G.dm = {}

-- If the border key is custom, then return the respective table otherwise
-- return the string as it is.
dm.border = setmetatable({
  -- https://en.wikipedia.org/wiki/Box-drawing_character
  edge = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
}, {
  __index = function(_, key)
    return key
  end,
})

dm.icons = {
  lsp_kind = {
    Text = '',
    Method = '',
    Function = '',
    Constructor = '',
    Field = '',
    Variable = '',
    Class = '',
    Interface = '',
    Module = '',
    Property = '',
    Unit = '',
    Value = '',
    Enum = '',
    Keyword = '',
    Snippet = '',
    Color = '',
    File = '',
    Reference = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = '',
    Event = '',
    Operator = '',
    TypeParameter = '',
  },
  error = '',
  warn = '',
  info = '',
  hint = '',
}

---@generic T
---@param ... T
---@return T
P = function(...)
  vim.pretty_print(...)
  return ...
end

-- Clear the 'require' cache and 'luacache' for the module name.
RELOAD = function(...)
  require('plenary.reload').reload_module(...)
end

-- Reload and require the given module name.
---@param name string
---@return any
R = function(name)
  RELOAD(name)
  return require(name)
end

do
  local output = '[timer]%s: %fms'
  local hrtime = vim.loop.hrtime
  local start = {}

  -- Simple interface for timing code chunks.
  _G.timer = {
    start = function()
      table.insert(start, hrtime())
    end,
    stop = function(info)
      print(
        output:format(
          info and ' ' .. info or '',
          (hrtime() - table.remove(start)) / 1e6
        )
      )
    end,
  }
end

do
  local notify

  local function setup()
    notify = require 'notify'
    notify.setup {
      stages = 'fade',
      background_colour = '#282828',
      icons = {
        ERROR = dm.icons.error,
        WARN = dm.icons.warn,
        INFO = dm.icons.info,
        DEBUG = '',
      },
    }
  end

  ---@class NotifyOpts
  ---@field timeout number
  ---@field title string
  ---@field icon string
  ---@field on_open function
  ---@field on_close function

  local levels = vim.log.levels

  -- Default values for the notification title as per the log level.
  local default_title = {
    [levels.TRACE] = 'Trace',
    [levels.DEBUG] = 'Debug',
    [levels.INFO] = 'Information',
    [levels.WARN] = 'Warning',
    [levels.ERROR] = 'Error',
  }

  -- Override the default `vim.notify` to open a floating window.
  ---@param msg string|string[]
  ---@param log_level? number|string
  ---@param opts? NotifyOpts
  vim.notify = function(msg, log_level, opts)
    -- Defer the plugin setup until the first notification call because
    -- it takes around 12ms to load.
    if not notify then
      setup()
    end
    log_level = log_level or levels.INFO
    opts = opts or {}
    opts.title = opts.title
      or (type(log_level) == 'string' and log_level)
      or default_title[log_level]
    notify(msg, log_level, opts)
  end

  -- Wrapper around `vim.notify` to simplify passing the `title` value.
  --
  -- Use `vim.notify` directly to use the default `title` values.
  ---@param title string
  ---@param msg string|string[]
  ---@param log_level? number|string
  dm.notify = function(title, msg, log_level)
    vim.notify(msg, log_level, { title = title })
  end
end

-- Convenience wrapper around `nvim_replace_termcodes()`.
--
-- Converts a string representation of a mapping's RHS (eg. "<Tab>") into an
-- internal representation (eg. "\t").
---@param str string
---@return string
function dm.escape(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end
