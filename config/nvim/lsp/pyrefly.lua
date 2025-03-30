---@type vim.lsp.Config
return {
  cmd = { 'pyrefly', 'lsp' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml' },
  single_file_support = true,
}
