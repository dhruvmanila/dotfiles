local fn = vim.fn
local api = vim.api

local provider = require 'dm.provider'

---@class Tabpage
---@field index integer
---@field name string
---@field flags string
---@field is_active boolean

-- Construct and return the tabline label.
---@param tabpage Tabpage
---@return string
local function tabpage_label(tabpage)
  return (tabpage.is_active and '%#TabLineSel#' or '%#TabLine#')
    .. '%'
    .. tabpage.index
    .. 'T' -- Starts mouse click target region
    .. '  '
    .. tabpage.index
    .. ': '
    .. tabpage.name
    .. tabpage.flags
    .. '  '
end

-- Collect and return a mapping from filename to all the tabpages with the
-- same filename.
---@return table<string, Tabpage[]>
local function collect_tabpages()
  local tabpages = {}
  local current_tabpagenr = api.nvim_tabpage_get_number(api.nvim_get_current_tabpage())
  for tabpagenr = 1, #api.nvim_list_tabpages() do
    local winnr = fn.tabpagewinnr(tabpagenr)
    local bufnr = fn.tabpagebuflist(tabpagenr)[winnr]
    local tabpage = {
      index = tabpagenr,
      name = api.nvim_buf_get_name(bufnr),
      flags = provider.buffer_flags(bufnr),
      is_active = tabpagenr == current_tabpagenr,
    }
    local filename = fn.fnamemodify(tabpage.name, ':t')
    tabpages[filename] = tabpages[filename] or {}
    table.insert(tabpages[filename], tabpage)
  end
  return tabpages
end

-- Provide the tabline.
---@return string
function _G.nvim_tabline()
  local labels = {}

  for filename, tabpages in pairs(collect_tabpages()) do
    if #tabpages == 1 then
      local tabpage = tabpages[1]
      tabpage.name = filename
      labels[tabpage.index] = tabpage_label(tabpage)
    else
      for _, tabpage in ipairs(tabpages) do
        local parts = vim.split(tabpage.name, '/', { trimempty = true })
        tabpage.name = parts[#parts - 1] .. '/' .. parts[#parts]
        labels[tabpage.index] = tabpage_label(tabpage)
      end
    end
  end

  local line = table.concat(labels, '')
  return line
    .. '%#TabLineFill#' -- After the last tab fill with TabLineFill
    .. '%T' -- Ends mouse click target region(s)
    .. '%='
    .. (vim.v.this_session ~= '' and '   ' or '')
end

-- Always show the tabline
vim.opt.showtabline = 2

-- Set the tabline
vim.opt.tabline = '%!v:lua.nvim_tabline()'
