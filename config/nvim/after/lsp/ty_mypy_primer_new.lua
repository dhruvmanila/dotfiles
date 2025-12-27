---@type vim.lsp.Config
return {
  cmd = { '/tmp/mypy_primer/ty_new/target/release/ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ty.toml' },
}
