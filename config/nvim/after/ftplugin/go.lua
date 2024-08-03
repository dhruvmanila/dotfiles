vim.opt_local.makeprg = 'go run %'

vim.keymap.set('n', 'go', function()
  vim.lsp.buf.code_action {
    context = {
      only = { vim.lsp.protocol.CodeActionKind.SourceOrganizeImports },
    },
    apply = true,
  }
end, {
  buffer = true,
  desc = 'go: code action: organize imports',
})
