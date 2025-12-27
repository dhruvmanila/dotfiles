---@type vim.lsp.Config
return {
  cmd = { '/tmp/mypy_primer/ty_old/target/release/ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ty.toml' },
}
