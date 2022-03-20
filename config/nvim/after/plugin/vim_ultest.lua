local g = vim.g

-- To make the test output colored.
---@see https://github.com/rcarriga/vim-ultest#configuration
g.ultest_use_pty = true

-- Do not show output popup automatically.
g.ultest_output_on_line = false

g.ultest_pass_sign = ' '
g.ultest_fail_sign = ' '

vim.keymap.set('n', '<leader>ts', '<Plug>(ultest-summary-toggle)')
vim.keymap.set('n', '<leader>tn', '<Plug>(ultest-run-nearest)')
vim.keymap.set('n', '<leader>tf', '<Plug>(ultest-run-file)')
vim.keymap.set('n', '<leader>tl', '<Plug>(ultest-run-last)')
vim.keymap.set('n', '<leader>to', '<Plug>(ultest-output-jump)')
