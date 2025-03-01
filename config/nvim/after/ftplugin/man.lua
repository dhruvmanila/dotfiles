local opts = { buffer = true, nowait = true }

vim.keymap.set('n', '<CR>', '<C-]>', opts)
vim.keymap.set('n', '<BS>', '<C-T>', opts)

-- Do not show the tabline if Neovim was opened as a MANPAGER.
if #vim.api.nvim_list_wins() == 1 then
  vim.o.showtabline = 0
end
