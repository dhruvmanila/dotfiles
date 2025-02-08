dm.log = require 'dm.log'

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

-- Alias to `vim.print`
P = vim.print

do
  local output = '[timer]%s: %fms'
  local hrtime = vim.uv.hrtime
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
  local nvim_notify = vim.notify

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
  ---@param opts? notify.Options
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function(msg, level, opts)
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
    return (package.loaded.notify or nvim_notify)(msg, level, opts)
  end

  -- Wrapper around `vim.notify` to simplify passing the `title` value.
  --
  -- Use `vim.notify` directly to use the default `title` values.
  ---@param title string
  ---@param msg string|string[]
  ---@param level? number|string
  ---@param opts? notify.Options
  ---@return notify.Record
  dm.notify = function(title, msg, level, opts)
    opts = vim.tbl_extend('keep', opts or {}, { title = title })
    return vim.notify(msg, level, opts)
  end
end

-- Check if the given command is executable.
---@param cmd string
---@return boolean
function dm.is_executable(cmd)
  return vim.fn.executable(cmd) > 0
end

-- Return `true` if the given path exists.
---@param path string
---@return boolean
function dm.path_exists(path)
  local _, err = vim.uv.fs_stat(path)
  return err == nil
end

-- Redraw the line at the center of the window, maintaining the cursor position.
-- This is equivalent to `normal! zz`.
function dm.center_cursor()
  vim.cmd.normal { 'zz', bang = true }
end
