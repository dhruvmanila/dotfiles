if vim.g.loaded_linter then
  return
end
vim.g.loaded_linter = true

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('dm__auto_linting', { clear = true }),
  callback = require('dm.linter').lint,
  desc = 'Lint the buffer',
})
