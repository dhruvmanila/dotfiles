vim.keymap.set('n', 'go', function()
  vim.lsp.buf.code_action {
    context = { only = { 'source.organizeImports' } },
    apply = true,
  }
end, {
  buffer = true,
  desc = 'go: code action: organize imports',
})
