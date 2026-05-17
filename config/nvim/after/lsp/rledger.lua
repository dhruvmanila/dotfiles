---@type vim.lsp.Config
return {
  cmd = { 'rledger-lsp' },
  filetypes = { 'beancount' },
  root_markers = { 'journal.beancount', '.git' },
}
