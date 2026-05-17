---@type vim.lsp.Config
return {
  root_markers = { 'journal.beancount', '.git' },
  init_options = {
    journal_file = 'journal.beancount',
  },
}
