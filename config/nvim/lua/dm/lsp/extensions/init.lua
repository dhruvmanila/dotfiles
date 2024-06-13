-- Client side extension for the language servers.
return {
  pyright = require 'dm.lsp.extensions.pyright',
  ruff = require 'dm.lsp.extensions.ruff',
  ruff_lsp = require 'dm.lsp.extensions.ruff',
  rust_analyzer = require 'dm.lsp.extensions.rust_analyzer',
}
