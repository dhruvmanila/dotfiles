-- LSP server configurations
---@return table<string, table|function>
return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Install: `npm install --global bash-language-server`
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/microsoft/vscode/tree/main/extensions/css-language-features/server
  -- Install: `npm install --global vscode-langservers-extracted`
  cssls = {},

  -- https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd
  -- Install: `xcode-select install` OR `brew install llvm`
  clangd = {},

  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  -- Install: `npm install --global dockerfile-language-server-nodejs`
  dockerls = {},

  -- https://github.com/golang/tools/tree/master/gopls
  -- Install: `go install golang.org/x/tools/gopls@latest`
  -- Settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    settings = {
      gopls = {
        analyses = {
          nilness = true,
          shadow = true,
          unusedparams = true,
          unusedwrite = true,
        },
        gofumpt = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        usePlaceholders = true,
      },
    },
    on_init = function(client)
      for line in io.lines 'go.mod' do
        if vim.startswith(line, 'module') then
          client.config.settings.gopls['local'] =
            vim.split(line, ' ', { plain = true })[2]
        end
      end
      client.notify(
        'workspace/didChangeConfiguration',
        { settings = client.config.settings }
      )
      return true
    end,
  },

  -- https://github.com/microsoft/vscode/tree/main/extensions/html-language-features/server
  -- Install: `npm install --global vscode-langservers-extracted`
  html = {
    filetypes = { 'html', 'htmldjango' },
  },

  -- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
  -- Install: `npm install --global vscode-langservers-extracted`
  -- Settings: https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
  jsonls = function()
    return {
      settings = {
        json = {
          schemas = vim.list_extend({
            {
              description = 'Lua language server config file',
              fileMatch = { '.luarc.json' },
              url = 'https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json',
            },
          }, require('schemastore').json.schemas()),
        },
      },
    }
  end,

  -- https://github.com/artempyanykh/marksman
  -- Install: Pre-built binaries from https://github.com/artempyanykh/marksman/releases
  marksman = {},

  -- https://github.com/microsoft/pyright
  -- Install: `npm install --global pyright`
  -- Settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true, -- Using isort
      },
      python = {
        analysis = {
          typeCheckingMode = 'off', -- Using mypy
        },
      },
    },
  },

  -- https://github.com/charliermarsh/ruff-lsp
  -- Install: `pipx install ruff-lsp`
  -- Settings: https://github.com/charliermarsh/ruff-lsp#settings
  ruff_lsp = {
    init_options = {
      settings = {
        -- Let's use the global executable. This can be upgraded irrespective
        -- of the bundled version.
        path = { '~/.local/bin/ruff' },
      },
    },
  },

  -- https://github.com/rust-lang/rust-analyzer
  -- Install:
  --   $ rustup component add --toolchain stable rust-analyzer
  --
  --   Optionally, symlink the executable to cargo bin directory.
  --   $ ln -sfv "$(rustup which --toolchain stable rust-analyzer)" "$CARGO_HOME/bin"
  --
  -- Settings: https://rust-analyzer.github.io/manual.html#configuration
  rust_analyzer = {
    cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = {
          command = 'clippy',
        },
      },
    },
  },

  -- https://github.com/LuaLS/lua-language-server
  -- Install: `brew install lua-language-server`
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
  lua_ls = {
    settings = {
      Lua = {
        codelens = {
          enable = true,
        },
        completion = {
          -- Do NOT show contextual words, I got `cmp-buffer` for that.
          showWord = 'Disable',
        },
        diagnostics = {
          globals = {
            'packer_plugins',
            -- Busted
            'after_each',
            'assert',
            'before_each',
            'describe',
            'insulate',
            'it',
            'match',
            'setup',
            'stub',
            'teardown',
          },
        },
        hint = {
          enable = true,
        },
        format = {
          enable = false,
        },
        workspace = {
          preloadFileSize = 1000,
          checkThirdParty = false,
        },
      },
    },
  },

  -- https://github.com/typescript-language-server/typescript-language-server
  -- Install: `npm install --global typescript typescript-language-server`
  -- Settings: https://github.com/typescript-language-server/typescript-language-server#initializationoptions
  tsserver = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- https://github.com/iamcco/vim-language-server
  -- Install: `npm install --global vim-language-server`
  vimls = {},

  -- https://github.com/redhat-developer/yaml-language-server
  -- Install: `npm install --global yaml-language-server`
  -- Settings: https://github.com/redhat-developer/yaml-language-server#language-server-settings
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          -- Specify this explicitly as the server gets confused with `hammerkit.json`
          ---@see https://github.com/redhat-developer/vscode-yaml/issues/565
          ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*',
        },
      },
    },
  },
}
