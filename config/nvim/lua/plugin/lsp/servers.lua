---Server configurations

return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/mattn/efm-langserver
  -- Settings: https://github.com/mattn/efm-langserver/blob/master/schema.json
  efm = {
    -- cmd = {'efm-langserver', '-logfile', '/tmp/efm.log', '-loglevel', '5'},
    init_options = { documentFormatting = true },
    filetypes = {'python'},
    settings = {
      rootMarkers = {'.git/', 'requirements.txt'},
      languages = {
        python = {
          {
            lintCommand = 'mypy --show-column-numbers --follow-imports silent --ignore-missing-imports',
            lintFormats = {
              '%f:%l:%c: %trror: %m',
              '%f:%l:%c: %tarning: %m',
              '%f:%l:%c: %tote: %m',
            },
            lintIgnoreExitCode = true,
          },
          {
            lintCommand = 'flake8 --stdin-display-name ${INPUT} -',
            lintStdin = true,
            lintFormats = {'%f:%l:%c: %m'},
            lintIgnoreExitCode = true,
          },
          {
            formatCommand = 'black -',
            formatStdin = true,
          },
          {
            formatCommand = 'isort --profile black -',
            formatStdin = true,
          },
        },
      },
    },
  },

  -- https://github.com/vscode-langservers/vscode-json-languageserver
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#jsonls
  jsonls = {},

  -- Settings: https://github.com/microsoft/pylance-release#settings-and-customization
  pylance = {
    settings = {
      python = {
        analysis = {
          completeFunctionParens = true,
          typeCheckingMode = 'off',  -- Using mypy
          -- https://github.com/microsoft/pylance-release/issues/1055
          indexing = false,
        }
      }
    }
  },

  -- https://github.com/microsoft/pyright
  -- Settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
  -- pyright = {
  --   settings = {
  --     pyright = {
  --       disableOrganizeImports = true  -- Using isort
  --     },
  --     python = {
  --       venvPath = os.getenv('HOME') .. '/.pyenv',
  --       analysis = {
  --         typeCheckingMode = 'off'  -- Using mypy
  --       },
  --     }
  --   }
  -- },

  -- https://github.com/sumneko/lua-language-server
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua
  sumneko_lua = {
    cmd = {
      os.getenv("HOME") .. "/git/lua-language-server/bin/macOS/lua-language-server",
      "-E",
      os.getenv("HOME") .. "/git/lua-language-server/main.lua"
    },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          enable = true,
          globals = {'vim'},
        },
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          },
          preloadFileSize = 1000,  -- Default: 100
        },
      },
    }
  },

  -- https://github.com/iamcco/vim-language-server
  vimls = {},

  -- https://github.com/redhat-developer/yaml-language-server
  -- Settings: https://github.com/redhat-developer/yaml-language-server#language-server-settings
  yamlls = {},
}
