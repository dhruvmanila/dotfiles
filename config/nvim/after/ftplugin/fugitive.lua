vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.list = false

-- Determine whether we have enough vertical space to move the fugitive buffer
-- in a vertical position.
--
-- Heuristics:
--   - Check if there is enough space available.
--   - Check if there are any vertical splits.
--
-- When opening the fugitive buffer for the first time, it is opened at the
-- bottom part of the editor with full width. This will be excluded from the
-- layout so that we only consider the top half of the editor.
--
-- NOTE: This should be called only if we are not already in a vertical position.
---@return boolean
local function has_vertical_space()
  if vim.o.columns <= 140 then
    return false
  end
  local layout = vim.fn.winlayout()
  layout = layout[2][1]
  return layout[1] ~= 'row'
end

-- Determine whether we are in a vertical fugitive window. This is determined
-- by looking at the position of the window.
---@return boolean
local function is_vertical_fugitive()
  local row, col = unpack(vim.api.nvim_win_get_position(0))
  return col > 0 and row == 1
end

local vertical_fugitive = is_vertical_fugitive()
if not vertical_fugitive and has_vertical_space() then
  vim.cmd 'wincmd L'
  vertical_fugitive = true
end

local opts = { buffer = true, nowait = true }
local ropts = { buffer = true, nowait = true, remap = true }

-- Setup the keybindings to open the window in the correct split.
if vertical_fugitive or vim.o.columns <= 140 then
  vim.keymap.set('n', 'gh', 'g?', ropts)
else
  vim.keymap.set('n', 'gh', '<Cmd>vertical help fugitive-map<CR>', opts)
  vim.keymap.set('n', 'cc', '<Cmd>vertical Git commit<CR>', opts)
end

vim.keymap.set('n', 'q', 'gq', ropts)

-- Easy toggle for inline diff
vim.keymap.set('n', '<Tab>', '=', ropts)
