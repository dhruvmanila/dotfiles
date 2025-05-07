---@type vim.lsp.Config
return {
  cmd = { dm.OS_HOMEDIR .. '/work/astral/ruff-test/target/debug/ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ty.toml' },
  single_file_support = true,
}
