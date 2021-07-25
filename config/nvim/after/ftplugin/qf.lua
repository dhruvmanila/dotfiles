local fn = vim.fn
local opt_local = vim.opt_local
local nnoremap = dm.nnoremap

-- Autosize quickfix to match its minimum content
-- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
local function adjust_height(minheight, maxheight)
  local height = math.max(math.min(fn.line "$", maxheight), minheight)
  vim.cmd(height .. "wincmd _")
end

nnoremap("q", "<Cmd>quit<CR>", { buffer = true, nowait = true })
nnoremap("o", "<CR>", { buffer = true, nowait = true })
nnoremap("O", "<CR><Cmd>cclose<CR>", { buffer = true, nowait = true })

-- Position the (global) quickfix window at the very bottom of the window
-- (useful for making sure that it appears underneath splits).
--
-- NOTE: Using a check here to make sure that window-specific location-lists
-- aren't effected, as they use the same `FileType` as quickfix-lists.
--
-- Taken from https://github.com/fatih/vim-go/issues/108#issuecomment-565131948.
if fn.getwininfo(fn.win_getid())[1].loclist ~= 1 then
  vim.cmd "wincmd J"
end

-- Some useful defaults
vim.cmd [[
setlocal nobuflisted
setlocal colorcolumn=
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no
setlocal nowrap
]]

-- Adjust the height of quickfix window to a minimum of 3 and maximum of 10.
adjust_height(3, 10)
vim.cmd "setlocal winfixheight"
