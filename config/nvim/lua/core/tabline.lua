local fn = vim.fn
local icons = require('core.icons').icons
local devicons = require('nvim-web-devicons')
local utils = require('core.utils')

local M = {}

local highlights = {
  TabLineSel = {guifg = '#ebdbb2', guibg = '#282828', gui = 'bold'},
  TabLine = {guifg = '#928374', guibg = '#242424'},
  TabLineFill = {guifg = '#928374', guibg = '#1e1e1e'},
}

---Setting up the highlights
function M.tabline_highlights()
  for hl_name, opts in pairs(highlights) do
    utils.highlight(hl_name, opts)
  end
end

---File flags provider.
---Supported flags: Readonly, modified.
---@param ctx table
---@return string
local function buf_flags(ctx)
  local icon = ''
  if ctx.readonly then
    icon = icons.lock
  elseif ctx.modifiable and ctx.buftype ~= 'prompt' then
    if ctx.modified then icon = icons.modified end
  end
  return icon
end

---Return the filename for the given context.
---If the buffer is active, then return the filepath from the Git root if we're
---in a Git repository else return the full path.
---
---For non-active buffers, 'help' filetype and 'terminal' buftype,
---return the filename (tail part).
---@param ctx table
---@return string
local function filename(ctx, is_active)
  if ctx.bufname and #ctx.bufname > 0 then
    local modifier
    if is_active and ctx.filetype ~= 'help' and ctx.buftype ~= 'terminal' then
      local worktree = vim.fn.FugitiveWorkTree()
      modifier = worktree ~= '' and ':s?' .. worktree .. '/??' or ':~:.'
    else
      modifier = ':p:t'
    end
    return fn.fnamemodify(ctx.bufname, modifier)
  elseif ctx.buftype == 'prompt' then
    return ctx.filetype == 'TelescopePrompt' and ctx.filetype or '[Prompt]'
  else
    return '[No Name]'
  end
end

---Return the filetype icon and highlight group.
---@param ctx table
---@return string, string
local function ft_icon(ctx)
  local extension = fn.fnamemodify(ctx.bufname, ':e')
  return devicons.get_icon(ctx.filename, extension, {default = true})
end

---Tabline labels
---@param tabnr integer
---@param is_active boolean
---@return string
local function tabline_label(tabnr, is_active)
  local buflist = fn.tabpagebuflist(tabnr)
  local winnr = fn.tabpagewinnr(tabnr)
  local curbuf = buflist[winnr]
  local curbo = vim.bo[curbuf]

  local ctx = {
    bufnr = curbuf,
    bufname = fn.bufname(curbuf),
    readonly = curbo.readonly,
    modifiable = curbo.modifiable,
    modified = curbo.modified,
    buftype = curbo.buftype,
    filetype = curbo.filetype,
  }
  ctx.filename = filename(ctx, is_active)

  local flags = buf_flags(ctx)
  local icon, icon_hl = ft_icon(ctx)
  icon_hl = is_active and icon_hl or 'TabLine'
  local flag_hl = is_active and 'YellowSign' or 'TabLine'
  local tab_hl = is_active and '%#TabLineSel#' or '%#TabLine#'
  local sep = is_active and '▌' or ' '

  return tab_hl
    .. '%' .. tabnr .. 'T'  -- Starts mouse click target region
    .. sep
    .. ' '
    .. tabnr
    .. '.  '
    .. '%#' .. icon_hl .. '#'
    .. icon
    .. tab_hl
    .. ' '
    .. ctx.filename
    .. '  '
    .. '%#' .. flag_hl .. '#'
    .. flags
    .. tab_hl
    .. ' '
end

---Provide the tabline
---@return string
function _G.nvim_tabline()
  local line = ''
  local current_tabpage = fn.tabpagenr()
  for i = 1, fn.tabpagenr('$') do
    local is_active = i == current_tabpage
    line = line .. tabline_label(i, is_active)
  end
  line = line
    .. '%#TabLineFill#'   -- After the last tab fill with TabLineFill
    .. '%T'               -- Ends mouse click target region(s)
    .. '%='
  return line
end

-- Set the tabline
vim.o.tabline = '%!v:lua.nvim_tabline()'

utils.create_augroups({
  custom_tabline = {
    [[VimEnter,ColorScheme * lua require('core.tabline').tabline_highlights()]],
  }
})

return M
