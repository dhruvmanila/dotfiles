local fn = vim.fn
local api = vim.api

local session = require 'dm.session'
local provider = require 'dm.provider'

-- Provide the tabline label for active and inactive tabpage.
---@param tabpagenr integer
---@param is_active boolean
---@return string
local function tabline_label(tabpagenr, is_active)
  local winnr = fn.tabpagewinnr(tabpagenr)
  local bufnr = fn.tabpagebuflist(tabpagenr)[winnr]
  local tabhl = is_active and '%#TabLineSel#' or '%#TabLine#'

  return tabhl
    .. '%'
    .. tabpagenr
    .. 'T' -- Starts mouse click target region
    .. '  '
    .. tabpagenr
    .. ': '
    .. provider.buffer_name(bufnr, ':t')
    .. provider.buffer_flags(bufnr)
    .. '  '
end

-- Provide the tabline.
---@return string
function _G.nvim_tabline()
  local line = ''
  local current_tabpagenr = api.nvim_tabpage_get_number(
    api.nvim_get_current_tabpage()
  )
  for tabpagenr = 1, #api.nvim_list_tabpages() do
    line = line .. tabline_label(tabpagenr, tabpagenr == current_tabpagenr)
  end
  local current_session = session.current()
  if current_session ~= '' then
    current_session = '  ' .. current_session .. ' '
  end
  return line
    .. '%#TabLineFill#' -- After the last tab fill with TabLineFill
    .. '%T' -- Ends mouse click target region(s)
    .. '%='
    .. current_session
end

-- Always show the tabline
vim.opt.showtabline = 2

-- Set the tabline
vim.opt.tabline = '%!v:lua.nvim_tabline()'
