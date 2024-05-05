-- Client side extension for the language servers.
return {
  pyright = require 'dm.lsp.extensions.pyright',
  ruff_lsp = require 'dm.lsp.extensions.ruff_lsp',
  rust_analyzer = require 'dm.lsp.extensions.rust_analyzer',
}
