dm.log = {
  levels = {
    TRACE = 'TRACE',
    DEBUG = 'DEBUG',
    INFO = 'INFO',
    WARN = 'WARN',
    ERROR = 'ERROR',
  },
}

-- Global log level for Neovim. This can be updated by setting the environment
-- variable `NVIM_LOG_LEVEL` to one of the allowed values (`dm.log.levels`).
---@type string
dm.current_log_level = 'WARN'
if vim.env.NVIM_LOG_LEVEL then
  dm.current_log_level = assert(
    dm.log.levels[vim.env.NVIM_LOG_LEVEL:upper()],
    ('Log level must be one of (trace, debug, info, warn, error), got: %q'):format(
      vim.env.NVIM_LOG_LEVEL
    )
  )
end

-- If the border key is custom, then return the respective table otherwise
-- return the string as it is.
local borders = setmetatable({
  -- https://en.wikipedia.org/wiki/Box-drawing_character
  edge = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
}, {
  __index = function(_, key)
    return key
  end,
})

dm.border = borders[dm.config.border_style]

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
  error = '',
  warn = '',
  info = '',
  hint = '󰌶',
}

---@generic T
---@param ... T
---@return T
P = function(...)
  vim.print(...)
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
      print(output:format(info and ' ' .. info or '', (hrtime() - table.remove(start)) / 1e6))
    end,
  }
end

do
  local notify

  -- Setup `nvim-notify` plugin.
  local function setup()
    notify = require 'notify'
    notify.setup {
      stages = 'fade',
      icons = {
        ERROR = dm.icons.error,
        WARN = dm.icons.warn,
        INFO = dm.icons.info,
        DEBUG = '',
      },
      on_open = function(winnr)
        vim.api.nvim_win_set_config(winnr, { zindex = 100 })
        vim.keymap.set('n', 'q', '<Cmd>bdelete<CR>', {
          buffer = vim.api.nvim_win_get_buf(winnr),
          nowait = true,
        })
        vim.wo[winnr].wrap = true
        vim.wo[winnr].showbreak = 'NONE'
      end,
      max_width = math.floor(vim.o.columns * 0.4),
    }
  end

  -- Default values for the notification title as per the log level.
  local default_title = {
    [vim.log.levels.TRACE] = 'Trace',
    [vim.log.levels.DEBUG] = 'Debug',
    [vim.log.levels.INFO] = 'Information',
    [vim.log.levels.WARN] = 'Warning',
    [vim.log.levels.ERROR] = 'Error',
  }

  -- Override the default `vim.notify` to open a floating window.
  ---@param msg string|string[]
  ---@param level? number|string
  ---@param opts? table `:help NotifyOptions`
  vim.notify = function(msg, level, opts)
    -- Defer the plugin setup until the first notification call.
    if not notify then
      setup()
    end
    level = level or vim.log.levels.INFO
    opts = opts or {}
    opts.title = opts.title or (type(level) == 'string' and level) or default_title[level]
    -- Provide a padding between the text and the border on both sides.
    if type(msg) == 'table' then
      msg = vim.tbl_map(function(line)
        return ' ' .. line .. ' '
      end, msg)
    else
      msg = ' ' .. msg:gsub('\n', ' \n ')
    end
    return notify(msg, level, opts)
  end

  -- Wrapper around `vim.notify` to simplify passing the `title` value.
  --
  -- Use `vim.notify` directly to use the default `title` values.
  ---@param title string
  ---@param msg string|string[]
  ---@param level? number|string
  ---@param opts? table
  dm.notify = function(title, msg, level, opts)
    opts = vim.tbl_extend('keep', opts or {}, { title = title })
    return vim.notify(msg, level, opts)
  end
end

-- Check if the given command is executable.
---@param cmd string
---@return boolean
function dm.executable(cmd)
  return vim.fn.executable(cmd) > 0
end

-- Return `true` if the given path exists, `false` otherwise
---@param path string
---@return boolean
function dm.path_exists(path)
  local _, err = vim.loop.fs_stat(path)
  return err == nil
end
