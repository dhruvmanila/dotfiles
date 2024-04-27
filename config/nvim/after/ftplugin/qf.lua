-- Autosize quickfix to match its minimum content
-- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
local function adjust_height(minheight, maxheight)
  local height = math.max(math.min(vim.api.nvim_buf_line_count(0), maxheight), minheight)
  vim.api.nvim_win_set_height(0, height)
end

local opts = { buffer = true, nowait = true }

vim.keymap.set('n', 'q', '<Cmd>quit<CR>', opts)
vim.keymap.set('n', 'o', '<CR>', opts)
vim.keymap.set('n', 'O', '<CR><Cmd>cclose<CR>', opts)

-- Position the (global) quickfix window at the very bottom of the window
-- (useful for making sure that it appears underneath splits).
--
-- NOTE: Using a check here to make sure that window-specific location-lists
-- aren't effected, as they use the same `FileType` as quickfix-lists.
--
-- Taken from https://github.com/fatih/vim-go/issues/108#issuecomment-565131948.
if vim.fn.getwininfo(vim.fn.win_getid())[1].loclist ~= 1 then
  vim.cmd.wincmd 'J'
end

-- Some useful defaults
vim.opt_local.buflisted = false
vim.opt_local.colorcolumn = ''
vim.opt_local.number = true
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = 'no'
vim.opt_local.wrap = false

-- Adjust the height of quickfix window to a minimum of 3 and maximum of 10.
adjust_height(3, 10)
vim.opt_local.winfixheight = true
