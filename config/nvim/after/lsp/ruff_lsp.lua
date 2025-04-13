-- https://github.com/astral-sh/ruff-lsp
-- Install: `uv tool install ruff-lsp@latest`
-- Settings: https://github.com/astral-sh/ruff-lsp#settings
---@type vim.lsp.Config
return {
  before_init = function(_, config)
    config.settings.path = { vim.fn.exepath 'ruff' }
  end,
}
