local opt_local = vim.opt_local
local nnoremap = dm.nnoremap

opt_local.list = false
opt_local.number = false
opt_local.relativenumber = false

local opts = { buffer = true, nowait = true }

nnoremap("q", "<Cmd>quit<CR>", opts)
nnoremap("<CR>", "<C-]>", opts)
nnoremap("<BS>", "<C-T>", opts)
