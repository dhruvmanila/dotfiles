local lint = require('dm.linter').lint

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('dm__auto_linting', { clear = true }),
  callback = lint,
  desc = 'Lint the buffer',
})
