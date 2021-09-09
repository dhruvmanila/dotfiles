local nnoremap = dm.nnoremap

local opts = { buffer = true, nowait = true }

nnoremap("q", "<Cmd>quit<CR>", opts)
nnoremap("<CR>", "<C-]>", opts)
nnoremap("<BS>", "<C-T>", opts)

-- Do not show the tabline if Neovim was opened as a MANPAGER.
if #vim.api.nvim_list_wins() == 1 then
  vim.o.showtabline = 0
end
