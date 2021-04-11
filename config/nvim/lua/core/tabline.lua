local fn = vim.fn
local icons = require('core.icons').icons
local devicons = require('nvim-web-devicons')

---@class Buffer
---@field public extension string,
---@field public path string,
---@field public id integer,
---@field public filename string,
---@field public icon string,
---@field public icon_highlight string,
---@field public diagnostics table
---@field public readonly boolean
---@field public modified boolean
---@field public modifiable boolean
---@field public buftype string
local Buffer = {}

---Create a new buffer class
---@param bufnr integer
---@return Buffer
function Buffer:new(bufnr)
  local buf = {id = bufnr, path = fn.bufname(bufnr)}

  buf.readonly = vim.bo[bufnr].readonly
  buf.modifiable = vim.bo[bufnr].modifiable
  buf.modified = vim.bo[bufnr].modified
  buf.buftype = vim.bo[bufnr].buftype
  buf.extension = fn.fnamemodify(buf.path, ":e")
  buf.filename = (buf.path and #buf.path > 0) and
    fn.fnamemodify(buf.path, ":p:t") or "[No Name]"
  buf.icon, buf.icon_highlight = devicons.get_icon(
    buf.filename, buf.extension, {default = true}
  )

  self.__index = self
  return setmetatable(buf, self)
end

---File flags provider.
---Supported flags: Readonly, modified.
---@return string
function Buffer:flags()
  local icon = ''
  if self.readonly then
    icon = icons.lock
  elseif self.modifiable then
    if self.modified then icon = icons.modified end
  end
  return icon
end

---Tabline labels
---@param tabnr integer
---@param is_active boolean
---@return string
local function tabline_label(tabnr, is_active)
  local tab_hl, sep
  if is_active then
    tab_hl = '%#TabLineSel#'
    sep = '▌'
  else
    tab_hl = '%#TabLine#'
    sep = ' '
  end

  local buflist = fn.tabpagebuflist(tabnr)
  local winnr = fn.tabpagewinnr(tabnr)
  local buffer = Buffer:new(buflist[winnr])
  local flags = buffer:flags()

  return tab_hl
    .. sep
    .. '%' .. tabnr .. 'T'  -- Starts mouse click target region
    .. ' '
    .. tabnr
    .. '.  '
    .. '%#' .. buffer.icon_highlight .. '#'
    .. buffer.icon
    .. tab_hl
    .. ' '
    .. buffer.filename
    .. '  '
    .. '%#YellowSign#'
    .. flags
    .. tab_hl
    .. ' '
end

---Provide the directory path to current file from the working directory
---@return string
local function current_dir()
  local dir = fn.expand('%:p:~:.:h')
  if dir and #dir > 1 then
    return '%#Normal#  ' .. icons.directory .. ' %#TabLineSel#' .. dir .. '  '
  end
  return ''
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
  line = line .. '%#TabLineFill#'   -- After the last tab fill with TabLineFill
  line = line .. '%T'               -- Ends mouse click target region(s)
  line = line .. '%=' .. current_dir()
  return line
end
