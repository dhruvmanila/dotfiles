-- Ref:
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/statusline
local fn = vim.fn
local contains = vim.tbl_contains
local devicons = require('nvim-web-devicons')
local icons = require('core.icons').icons
local spinner_frames = require('core.icons').spinner_frames
local utils = require('core.utils')
local lsp_status = require('lsp-status')

local M = {}

-- Colors are taken from the current colorscheme
-- TODO: Any way of taking the values directly from the common highligh groups?
local colors = {
  active_bg     = '#3a3735',
  inactive_bg   = '#32302f',
  active_fg     = '#e2cca9',
  inactive_fg   = '#7c6f64',
}

local palette = {
  grey          = '#a89984',
  yellow        = '#e9b143',
  green         = '#b0b846',
  orange        = '#f28534',
  red           = '#f2594b',
  aqua          = '#8bba7f',
  blue          = '#80aa9e',
  purple        = '#d3869b',
}

---Table to create special highlight groups.
local highlights = {
  StatusLine = {guifg = colors.active_fg, guibg = colors.active_bg},
  StatusLineNC = {guifg = colors.inactive_fg, guibg = colors.inactive_bg},
  StSpecialBuffer = {guifg = colors.active_fg, guibg = colors.active_bg, gui = 'bold'}
}

---Create the highlight groups for the statusline from the given palette.
---This will create groups with names as 'St<colorname><attribute>' where
---colorname is Capitalized and attribute can be '', 'Bold' or 'Italic'
---@param prefix string (Default: 'St')
function M.statusline_highlights(prefix)
  prefix = prefix or 'St'
  for name, hex in pairs(palette) do
    name = name:gsub('^%l', string.upper)
    utils.highlight(prefix .. name, {guifg = hex, guibg = colors.active_bg})
    utils.highlight(
      prefix .. name .. 'Bold',
      {guifg = hex, guibg = colors.active_bg, gui = 'bold'}
    )
    utils.highlight(
      prefix .. name .. 'Italic',
      {guifg = hex, guibg = colors.active_bg, gui = 'italic'}
    )
  end

  ---Setting the special highlight groups.
  for hl_name, opts in pairs(highlights) do
    utils.highlight(hl_name, opts)
  end
end

---Special buffer information table.
---
---This includes the following components:
---types: List containing special buffer filetype or buftype.
---name: The name value to be displayed. It can be either a string or a
---      function where the `ctx` variable will be passed as the only argument.
---icon: Table containing the icon for the special buffer.
---color: Table containing the color of the icon.
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
      return 'Quickfix List ' .. title .. '  %l/%L'
    end,

    help = function(ctx)
      return 'help [' .. fn.fnamemodify(ctx.bufname, ':t:r') .. ']  %l/%L'
    end,

    dirvish = function(ctx)
      return '%<' .. fn.fnamemodify(ctx.bufname, ':~') .. ' '
    end,

    vista_kind = function(_)
      return 'Vista' .. ' [' .. vim.g.vista.provider .. ']'
    end,

    man = function(ctx)
      local title = fn.fnamemodify(ctx.bufname, ':t')
      return 'Man' .. ' [' .. title .. ']  %l/%L'
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
  return hl and '%#' .. hl .. '#' or ''
end

---Return the line information.
---Current format: total:col
---@param hl string
---@return string
local function lineinfo(hl)
  hl = wrap_hl(hl)
  return hl .. ' %L:%-2c' .. ' %*'  -- ℓ 𝚌
end

-- TODO: Do I even need this?
local function file_detail(hl)
  local encode = vim.bo.fenc ~= '' and vim.bo.fenc or vim.o.enc
  local format = vim.bo.fileformat
  return ' ' .. wrap_hl(hl) .. encode:upper() .. ' ' .. format:upper() .. ' %*'
end

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
local function python_version(ctx, hl)
  if ctx.filetype == 'python' then
    local env = os.getenv('VIRTUAL_ENV')
    local version = vim.g.current_python_version
    if env or version then
      env = env and '(' .. fn.fnamemodify(env, ':t') .. ') ' or ''
      version = version and ' ' .. version .. ' ' or ''
      return wrap_hl(hl) .. version .. env .. '%*'
    end
  end
  return ''
end

---Return the number of GitHub notifications.
---@param hl string
---@return string
local function github_notifications(hl)
  local notifications = vim.g.github_notifications
  if notifications and notifications > 0 then
    return wrap_hl(hl) .. icons.github .. ' ' .. notifications .. ' %*'
  end
  return ''
end

---Return the diagnostics information for the given severity if > 0.
---@param ctx table
---@param opts table
---@return string
local function lsp_diagnostics(ctx, opts)
  local curbuf = ctx.curbuf
  local result = ''
  for _, o in ipairs(opts) do
    local count = vim.lsp.diagnostic.get_count(curbuf, o.severity)
    if count > 0 then
      result = result .. wrap_hl(o.hl) .. o.icon .. ' ' .. count .. ' %*'
    end
  end
  return result ~= '' and ' ' .. result or result
end

---Return the current function value from the LSP server.
---@param hl string
---@return string
local function lsp_current_function(hl)
  local current_function = vim.b.lsp_current_function
  if current_function and current_function ~= '' then
    return wrap_hl(hl) .. ' ' .. current_function .. ' %*'
  end
  return ''
end

---Neovim LSP messages
---Ref: https://github.com/nvim-lua/lsp-status.nvim/blob/master/lua/lsp-status/statusline.lua#L37
---@return string|nil
local function lsp_messages()
  local messages = fn.uniq(lsp_status.messages())
  local msgs = {}

  for _, msg in ipairs(messages) do
    local client_name = 'LSP[' .. msg.name .. ']:'
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
  if status ~= '' then return status .. ' ' end
end

---Create the statusline for the inactive buffer.
---@param ctx table
---@return string
local function inactive_statusline(ctx, prefix)
  local extension = fn.fnamemodify(ctx.bufname, ':e')
  local filename = fn.fnamemodify(ctx.bufname, ':p:t')
  local icon, _ = devicons.get_icon(filename, extension, {default = true})
  return prefix
    .. ' '
    .. icon
    .. ' %<'
    .. fn.fnamemodify(ctx.bufname, ':~:.')
    .. ' '
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
local function special_buffer_statusline(ctx, inactive, prefix)
  local typ = ctx.filetype ~= '' and ctx.filetype or ctx.buftype
  local name = special_buffer_name(ctx, typ)
  local icon = special_buffer_info.icon[typ] or ''
  local color = special_buffer_info.color[typ]
  local hl = inactive and '' or wrap_hl(color)
  local name_hl = inactive and '' or wrap_hl('StSpecialBuffer')

  return prefix
    .. ' '
    .. hl
    .. icon
    .. '%* '
    .. name_hl
    .. name
    .. '%='
end

---Provide the statusline for different types of buffers including active,
---inactive, special buffers such as NvimTree, Terminal, quickfix, etc.
---@return string
function _G.nvim_statusline()
  local prefix = '▌'
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
    return special_buffer_statusline(ctx, inactive, prefix)
  elseif inactive then
    return inactive_statusline(ctx, prefix)
  end

  local messages = lsp_messages()
  if messages then
    return wrap_hl('StSpecialBuffer') .. prefix .. ' ' .. messages
  end

  return wrap_hl('StAqua')
    .. prefix
    .. '%*'
    .. lineinfo('StSpecialBuffer')
    .. git_status_info('head', icons.git_branch, 'StGreenBold')
    .. '%<'
    -- .. git_status_info('added', icons.diff_added, 'StGreen')
    -- .. git_status_info('changed', icons.diff_modified, 'StBlue')
    -- .. git_status_info('removed', icons.diff_removed, 'StRed')
    .. ' '
    .. lsp_current_function('StGrey')
    .. '%='
    .. github_notifications('StOrange')
    .. python_version(ctx, 'StBlueBold')
    .. file_detail()
    .. lsp_diagnostics(
      ctx,
      {
        {severity = 'Information', icon = icons.info, hl = 'StBlue'},
        {severity = 'Hint', icon = icons.hint, hl = 'StAqua'},
        {severity = 'Warning', icon = icons.warning, hl = 'StYellow'},
        {severity = 'Error', icon = icons.error, hl = 'StRed'},
      }
    )
end

---Create a timer for the given task and interval.
---@param interval integer (ms)
---@param task function
---@return nil
local function job(interval, task)
  -- A one-shot job to initialize the data
  vim.defer_fn(task, 100)
  -- Start the job every 'interval' milliseconds ad infinitum
  fn.timer_start(interval, task, {['repeat'] = -1})
end

---Function to start a job which sets the current Python version.
local function set_python_version()
  fn.jobstart(
    'python --version',
    {
      stdout_buffered = true,
      on_stdout = function(_, data, _)
        if data and data[1] ~= '' then
          vim.g.current_python_version = data[1]
        end
      end
    }
  )
end

---Function to start a job which sets the number of GitHub notifications.
local function fetch_github_notifications()
  fn.jobstart(
    "gh api notifications",
    {
      stdout_buffered = true,
      on_stdout = function(_, data, _)
        if data and data[1] ~= "" then
          local notifications = vim.fn.json_decode(data)
          vim.g.github_notifications = #notifications
        end
      end
    }
  )
end

function M.python_version_job()
  if fn.executable('python') > 0 then
    job(5 * 1000, set_python_version)
  end
end

function M.github_notifications_job()
  if fn.executable('gh') > 0 then
    job(5 * 60 * 1000, fetch_github_notifications)
  end
end

utils.create_augroups({
  custom_statusline = {
    [[VimEnter,ColorScheme * lua require('core.statusline').statusline_highlights()]],
    [[FileType python lua require('core.statusline').python_version_job()]],
    [[VimEnter * lua require('core.statusline').github_notifications_job()]],
  }
})

-- :h qf.vim, disable quickfix statusline
vim.g.qf_disable_statusline = 1

-- Set the statusline
vim.o.statusline = "%!v:lua.nvim_statusline()"

return M
