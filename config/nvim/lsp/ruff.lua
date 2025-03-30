-- Repository: https://github.com/astral-sh/ruff
-- Documentation: https://docs.astral.sh/ruff/editors/
-- Install: `uv tool install ruff@latest`
---@type vim.lsp.Config
return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
  single_file_support = true,
  init_options = {
    settings = {
      logLevel = 'debug',
      logFile = vim.fn.stdpath 'log' .. '/lsp.ruff.log',
    },
  },
}
