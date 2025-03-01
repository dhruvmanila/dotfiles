if vim.g.colors_name then
  vim.cmd.highlight 'clear'
end

vim.g.colors_name = 'gruvbox_dark'
vim.o.termguicolors = true

require('dm.themes.gruvbox').load 'dark'
