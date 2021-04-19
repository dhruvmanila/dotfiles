-- Ref:
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/statusline
local fn = vim.fn
local devicons = require('nvim-web-devicons')
local icons = require('core.icons').icons
local spinner_frames = require('core.icons').spinner_frames
local utils = require('core.utils')
local lsp_status = require('lsp-status')
local contains = vim.tbl_contains

-- Colors are taken from the current colorscheme
-- TODO: When changing the colorscheme, define its own set and create a table
-- with each entry as a map from g.colors_name to colors value.
local colors = {
  active_bg     = '#3a3735',
  inactive_bg   = '#32302f',
  active_fg     = '#e2cca9',
  inactive_fg   = '#7c6f64',
  grey          = '#a89984',
  yellow        = '#e9b143',
  green         = '#b0b846',
  orange        = '#f28534',
  red           = '#f2594b',
  aqua          = '#8bba7f',
  blue          = '#80aa9e',
  purple        = '#d3869b',
}

local highlights = {
  StatusLine = {guifg = colors.active_fg, guibg = colors.active_bg},
  StatusLineNC = {guifg = colors.inactive_fg, guibg = colors.inactive_bg},
  StNormalMode = {guifg = colors.active_bg, guibg = colors.grey, gui = 'bold'},
  StInsertMode = {guifg = colors.active_bg, guibg = colors.green, gui = 'bold'},
  StVisualMode = {guifg = colors.active_bg, guibg = colors.red, gui = 'bold'},
  StReplaceMode = {guifg = colors.active_bg, guibg = colors.yellow, gui = 'bold'},
  StCommandMode = {guifg = colors.active_bg, guibg = colors.blue, gui = 'bold'},
  StTerminalMode = {guifg = colors.active_bg, guibg = colors.purple, gui = 'bold'},
  StRed = {guifg = colors.red, guibg = colors.active_bg},
  StGreen = {guifg = colors.green, guibg = colors.active_bg},
  StGreenBold = {guifg = colors.green, guibg = colors.active_bg, gui = 'bold'},
  StBlue = {guifg = colors.blue, guibg = colors.active_bg},
  StAqua = {guifg = colors.aqua, guibg = colors.active_bg},
  StYellow = {guifg = colors.yellow, guibg = colors.active_bg},
  StYellowBold = {guifg = colors.yellow, guibg = colors.active_bg, gui = 'bold'},
  StGrey = {guifg = colors.grey, guibg = colors.active_bg},
  StOrange = {guifg = colors.orange, guibg = colors.active_bg},
  StSpecialBuffer = {guifg = colors.active_fg, guibg = colors.active_bg, gui = 'bold'}
}

---Setting the highlights
for hl_name, opts in pairs(highlights) do
  utils.highlight(hl_name, opts)
end

---Mode data
---1. Full  2. Short  3. Highlight
local modes = {
  n      = {'NORMAL',    'N',    'StNormalMode'},
  no     = {'N·OpPd',    'N·OP', 'StNormalMode'},
  i      = {'INSERT',    'I',    'StInsertMode'},
  ic     = {'I·COMPL',   'I·CO', 'StInsertMode'},
  c      = {'COMMAND',   'C',    'StCommandMode'},
  v      = {'VISUAL',    'V',    'StVisualMode'},
  V      = {'V·LINE',    'V·L',  'StVisualMode'},
  [''] = {'V·BLOCK',   'V·B',  'StVisualMode'},
  s      = {'SELECT',    'S',    'StVisualMode'},
  S      = {'S·LINE',    'S·L',  'StVisualMode'},
  [''] = {'S·BLOCK',   'S·B',  'StVisualMode'},
  R      = {'REPLACE',   'R',    'StReplaceMode'},
  Rv     = {'V·REPLACE', 'V·R',  'StReplaceMode'},
  ['r']  = {'PROMPT',    'P',    'StNormalMode'},
  ['r?'] = {'CONFIRM',   'C',    'StNormalMode'},
  rm     = {'MORE',      'M',    'StNormalMode'},
  ['!']  = {'SHELL',     '!',    'StNormalMode'},
  t      = {'TERMINAL',  'T',    'StTerminalMode'},
}

---LSP server name aliases (displayed in the LSP messages)
local aliases = {
  pyright = 'Pyright',
  bash_ls = 'Bash LS',
  sumneko_lua = 'Sumneko',
}

---Special buffer information table.
---
---This includes three components:
---types: List containing special buffer filetype or buftype.
---mode: List containing types for which to display the mode.
---lineinfo: List containing types for which to display the lineinfo.
---name: The name value to be displayed. It can be either a string or a
---      function where the `ctx` variable will be passed as the only argument.
---icon: Table containing the icon and its color for the buffer
---
---Special buffers included in `special_buffer_info` can be excluded from this
---table which will mean to not display anything for that buffer.
local special_buffer_info = {
  types = {
    'qf',
    'terminal',
    'help',
    'tsplayground',
    'NvimTree',
    'dirvish',
    'fugitive',
    'startify',
    'packer',
    'gitcommit',
    'vista_kind',
    'man',
  },
  mode = {
    'terminal',
    'gitcommit',
  },
  lineinfo = {
    'man',
    'gitcommit',
    'help',
  },
  name = {
    terminal = 'Terminal',
    tsplayground = 'TSPlayground',
    NvimTree = 'NvimTree',
    fugitive = 'Fugitive',
    packer = 'Packer',
    gitcommit = 'Commit message',

    qf = function(ctx)
      local title = utils.get_var('w', ctx.curwin, 'quickfix_title')
      title = title and '[' .. title .. ']' or ''
      return 'Quickfix List ' .. title .. ' %l/%L'
    end,

    help = function(ctx)
      return 'help [' .. fn.fnamemodify(ctx.bufname, ':t:r') .. ']'
    end,

    dirvish = function(ctx) return fn.fnamemodify(ctx.bufname, ':~') end,

    vista_kind = function(_)
      return 'Vista' .. ' [' .. vim.g.vista.provider .. ']'
    end,

    man = function(ctx)
      return 'Man' .. ' [' .. fn.fnamemodify(ctx.bufname, ':t') .. ']'
    end,
  },
  icon = {
    qf = icons.lists,
    terminal = icons.terminal,
    help = icons.info,
    tsplayground = icons.tree,
    NvimTree = icons.directory,
    dirvish = icons.directory,
    fugitive = icons.git_logo,
    packer = icons.package,
    gitcommit = icons.git_commit,
    vista_kind = icons.tag,
    man = icons.book,
  },
  color = {
    qf = 'StRed',
    terminal = 'StYellow',
    help = 'StYellow',
    tsplayground = 'StGreen',
    NvimTree = 'StBlue',
    dirvish = 'StBlue',
    fugitive = 'StYellow',
    packer = 'StAqua',
    gitcommit = 'StYellow',
    vista_kind = 'StBlue',
    man = 'StOrange',
  },
}


---Wrap the highlight for statusline.
---@param hl string
---@return string
local function wrap_hl(hl)
  return '%#' .. hl .. '#'
end

---Return the mode component.
---the mode text.
---@return string
local function mode_component()
  local mode_info = modes[fn.mode()]
  return wrap_hl(mode_info[3]) .. ' ' .. mode_info[1] .. ' %*'
end

---Return the line information.
---Current format: ℓ 12/245 𝚌 15
---@param hl string
---@return string
local function lineinfo(hl)
  hl = hl and wrap_hl(hl) or wrap_hl('StNormalMode')
  return hl .. ' ℓ %2l/%L ' .. '𝚌 %-2c%< '
end

-- TODO: Do I even need this?
-- local function file_detail()
--   local encode = vim.bo.fenc ~= '' and vim.bo.fenc or vim.o.enc
--   local format = vim.bo.fileformat
--   return encode:upper() .. ' ' .. format:upper() .. ' '
-- end

---Return the Git status information according to the given field value.
---@param field string (head|added|changed|removed)
---@param icon string
---@param hl string
---@return string
local function git_status_info(field, icon, hl)
  local status_dict = vim.b.gitsigns_status_dict
  if status_dict then
    local info = status_dict[field]
    if info then
      if type(info) == 'number' then
        if info > 0 then
          return ' ' .. wrap_hl(hl) .. icon .. ' ' .. info .. '%*'
        end
      elseif info ~= '' then
        return ' ' .. wrap_hl(hl) .. icon .. ' ' .. info .. '%*'
      end
    end
  end
  return ''
end

---Return the Python virtual environment name if we are in any.
---@param ctx table
---@return string
local function python_venv(ctx, hl)
  if ctx.filetype == 'python' then
    local env = os.getenv('VIRTUAL_ENV')
    if env then
      return wrap_hl(hl)
        .. icons.python
        .. ' '
        .. fn.fnamemodify(env, ':t')
        .. '%* '
    end
  end
  return ''
end

---Return the diagnostics information for the given severity if > 0.
---@param ctx table
---@param severity string
---@param icon string
---@param hl string
---@return string
local function lsp_diagnostics(ctx, severity, icon, hl)
  local count = vim.lsp.diagnostic.get_count(ctx.curbuf, severity)
  if count > 0 then
    return wrap_hl(hl) .. icon .. ' ' .. count .. ' '
  end
  return ''
end

---Return the current function value from the LSP server.
---@param hl string
---@return string
local function lsp_current_function(hl)
  hl = hl and wrap_hl(hl) or ''
  local current_function = vim.b.lsp_current_function
  if current_function and current_function ~= '' then
    return hl .. '(' .. current_function .. ')'
  end
  return ''
end

---Neovim LSP messages
---Ref: https://github.com/nvim-lua/lsp-status.nvim/blob/master/lua/lsp-status/statusline.lua#L37
---@return string
local function lsp_messages()
  local messages = fn.uniq(lsp_status.messages())
  local msgs = {}

  for _, msg in ipairs(messages) do
    local name = aliases[msg.name] or msg.name
    local client_name = '[' .. name .. ']'
    local contents
    if msg.progress then
      contents = msg.title
      if msg.message then contents = contents .. ' ' .. msg.message end
      if msg.percentage then contents = contents .. '(' .. msg.percentage .. ')' end
      if msg.spinner then
        contents = spinner_frames[(msg.spinner % #spinner_frames) + 1] .. ' ' .. contents
      end
    elseif msg.status then
      contents = msg.content
      if msg.uri then
        local filename = vim.uri_to_fname(msg.uri)
        filename = fn.fnamemodify(filename, ':~:.')
        local space = math.min(60, math.floor(0.6 * fn.winwidth(0)))
        if #filename > space then filename = fn.pathshorten(filename) end
        contents = '(' .. filename .. ') ' .. contents
      end
    else
      contents = msg.content
    end
    table.insert(msgs, client_name .. ' ' .. contents)
  end

  local status = vim.trim(table.concat(msgs, ' '))
  if status ~= '' then return status .. ' ' else return '' end
end

---Create the statusline for the inactive buffer.
---@param ctx table
---@return string
local function inactive_statusline(ctx)
  local extension = fn.fnamemodify(ctx.bufname, ':e')
  local filename = fn.fnamemodify(ctx.bufname, ':p:t')
  local icon, _ = devicons.get_icon(filename, extension, {default = true})
  return ' ' .. icon .. ' %<' .. fn.fnamemodify(ctx.bufname, ':~:.') .. ' '
end

---Determine whether we are in a special buffer or not.
---@param ctx table
---@return boolean
local function special_buffer(ctx)
  return contains(special_buffer_info.types, ctx.filetype) or
    contains(special_buffer_info.types, ctx.buftype)
end

---Returns the name of the special buffer as per the name table values of
---the special_buffer_info variable.
---@param ctx table
---@param typ string
---@return string
local function special_buffer_name(ctx, typ)
  local name = special_buffer_info.name[typ] or ''
  if type(name) == 'function' then
    return name(ctx)
  else
    return name
  end
end

---Return the statusline for special builtin buffers such as Quickfix, Terminal
---and plugin buffers such as NvimTree, TSPlayground, etc.
---@param ctx table
---@param inactive boolean
---@return string
local function special_buffer_statusline(ctx, inactive)
  local typ = ctx.filetype ~= '' and ctx.filetype or ctx.buftype
  local name = special_buffer_name(ctx, typ)
  local icon = special_buffer_info.icon[typ] or ''
  local color = special_buffer_info.color[typ]
  local hl = (inactive or not color) and '' or wrap_hl(color)
  local name_hl = inactive and '' or wrap_hl('StSpecialBuffer')
  local prefix = (not inactive and contains(special_buffer_info.mode, typ)) and
    mode_component() or '▌'
  local suffix = (not inactive and contains(special_buffer_info.lineinfo, typ))
    and lineinfo() or ''

  return prefix
    .. ' '
    .. hl
    .. icon
    .. '%* '
    .. name_hl
    .. name
    .. '%='
    .. suffix
end

---Provide the statusline for different types of buffers including active,
---inactive, special buffers such as NvimTree, Terminal, quickfix, etc.
---@return string
function _G.nvim_statusline()
  local curwin = vim.g.statusline_winid or 0
  local curbuf = vim.api.nvim_win_get_buf(curwin)
  local curbo = vim.bo[curbuf]
  local inactive = vim.api.nvim_get_current_win() ~= curwin

  local ctx = {
    curwin = curwin,
    curbuf = curbuf,
    bufname = fn.bufname(curbuf),
    filetype = curbo.filetype,
    buftype = curbo.buftype,
  }

  if special_buffer(ctx) then
    return special_buffer_statusline(ctx, inactive)
  elseif inactive then
    return inactive_statusline(ctx)
  end

  return mode_component()
    -- TODO: Do I even need the diff count?
    .. git_status_info('head', icons.git_branch, 'StGreenBold')
    .. '%<'
    -- .. git_status_info('added', icons.diff_added, 'StGreen')
    -- .. git_status_info('changed', icons.diff_modified, 'StBlue')
    -- .. git_status_info('removed', icons.diff_removed, 'StRed')
    .. ' '
    .. lsp_current_function('StGrey')
    .. '%='
    .. lsp_diagnostics(ctx, 'Information', icons.info, 'StBlue')
    .. lsp_diagnostics(ctx, 'Hint', icons.hint, 'StAqua')
    .. lsp_diagnostics(ctx, 'Warning', icons.warning, 'StYellow')
    .. lsp_diagnostics(ctx, 'Error', icons.error, 'StRed')
    .. python_venv(ctx, 'StYellowBold')
    .. lineinfo()
    .. lsp_messages()
end

-- :h qf.vim, disable quickfix statusline
vim.g.qf_disable_statusline = 1

-- Set the statusline
vim.o.statusline = "%!v:lua.nvim_statusline()"
