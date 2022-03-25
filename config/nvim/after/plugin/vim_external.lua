vim.g.external_search_engine = 'https://duckduckgo.com/?q='

-- Open current buffer directory in finder
vim.keymap.set('n', '<leader>ee', '<Plug>(external-explorer)')

-- Similar to netrw
vim.keymap.set('n', 'gx', '<Plug>(external-browser)')
