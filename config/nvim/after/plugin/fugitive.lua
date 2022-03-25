-- 'gs' originally means goto sleep for {count} seconds which is of no use
vim.keymap.set('n', 'gs', '<Cmd>Git<CR>')
vim.keymap.set('n', 'g<Space>', ':Git<Space>')
vim.keymap.set('n', '<leader>gp', '<Cmd>Git push<CR>')
vim.keymap.set('n', '<leader>gP', '<Cmd>Git push --force-with-lease<CR>')
