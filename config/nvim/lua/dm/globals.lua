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

  -- Setup `nvim-notify` plugin.
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
      on_open = function(winnr)
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
    opts.title = opts.title
      or (type(level) == 'string' and level)
      or default_title[level]
    -- Provide a padding between the text and the border on both sides.
    if type(msg) == 'table' then
      msg = vim.tbl_map(function(line)
        return ' ' .. line .. ' '
      end, msg)
    else
      msg = ' ' .. msg:gsub('\n', ' \n ')
    end
    notify(msg, level, opts)
  end

  -- Wrapper around `vim.notify` to simplify passing the `title` value.
  --
  -- Use `vim.notify` directly to use the default `title` values.
  ---@param title string
  ---@param msg string|string[]
  ---@param level? number|string
  dm.notify = function(title, msg, level)
    vim.notify(msg, level, { title = title })
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
