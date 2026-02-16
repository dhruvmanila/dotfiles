-- https://github.com/rust-lang/rust-analyzer
-- Install: `rustup component add rust-analyzer`
-- Settings: https://rust-analyzer.github.io/book/configuration.html
---@type vim.lsp.Config
return {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        features = 'all',
        buildScripts = {
          enable = true,
        },
      },
      checkOnSave = false,
      check = {
        command = 'clippy',
      },
      inlayHints = {
        closingBraceHints = {
          enable = false,
        },
      },
      lens = {
        implementations = {
          enable = false,
        },
        references = {
          adt = {
            enable = false,
          },
          enumVariant = {
            enable = false,
          },
          method = {
            enable = false,
          },
          trait = {
            enable = false,
          },
        },
      },
      procMacro = {
        enable = true,
      },
      references = {
        excludeImports = true,
      },
    },
  },
  capabilities = {
    -- See: ./config/nvim/lua/dm/lsp/extensions/rust_analyzer.lua
    experimental = {
      commands = {
        commands = {
          'rust-analyzer.runSingle',
          'rust-analyzer.debugSingle',
          'rust-analyzer.showReferences',
          'rust-analyzer.gotoLocation',
        },
      },
      matchingBrace = true,
      openCargoToml = true,
      serverStatusNotification = false,
    },
  },
}
