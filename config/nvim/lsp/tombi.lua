-- Repository: https://github.com/tombi-toml/tombi
-- Documentation: https://tombi-toml.github.io/tombi/docs
-- Install: `uv tool install tombi@latest`
---@type vim.lsp.Config
return {
  cmd = { 'tombi', 'serve' },
  filetypes = { 'toml' },
  single_file_support = true,
}
