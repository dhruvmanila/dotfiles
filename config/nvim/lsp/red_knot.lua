---@type vim.lsp.Config
return {
  cmd = { dm.OS_HOMEDIR .. '/work/astral/ruff/target/debug/red_knot', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'knot.toml' },
  single_file_support = true,
  init_options = {
    settings = {
      logLevel = 'info',
      logFile = vim.fn.stdpath 'log' .. '/lsp.red_knot.log',
    },
  },
}
