require('nvim-test').setup {
  silent = true,
  termOpts = {
    direction = 'horizontal',
    go_back = true,
    stopinsert = true,
    height = math.floor(vim.o.lines * 0.4),
    width = math.floor(vim.o.columns * 0.4),
  },
}

vim.keymap.set('n', '<leader>ti', '<Cmd>TestInfo<CR>')
vim.keymap.set('n', '<leader>tn', '<Cmd>TestNearest<CR>')
vim.keymap.set('n', '<leader>tf', '<Cmd>TestFile<CR>')
vim.keymap.set('n', '<leader>ts', '<Cmd>TestSuite<CR>')
vim.keymap.set('n', '<leader>tl', '<Cmd>TestLast<CR>')
