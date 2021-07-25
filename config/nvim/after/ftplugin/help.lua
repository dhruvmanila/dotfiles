local nnoremap = dm.nnoremap

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
setlocal nolist
]]

local opts = { buffer = true, nowait = true }

nnoremap("q", "<Cmd>quit<CR>", opts)
nnoremap("<CR>", "<C-]>", opts)
nnoremap("<BS>", "<C-T>", opts)
