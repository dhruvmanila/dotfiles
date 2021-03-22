-- Ref: https://github.com/itchyny/vim-external
local map = vim.api.nvim_set_keymap

vim.g.external_search_engine = 'https://duckduckgo.com/?q='

map('n', '<Leader>ee', '<Plug>(external-editor)',   {})
map('n', '<Leader>en', '<Plug>(external-explorer)', {})
map('n', '<Leader>eb', '<Plug>(external-browser)',  {})
