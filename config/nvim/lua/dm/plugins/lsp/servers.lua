local M = vim.lsp.protocol.Methods

local extensions = require 'dm.plugins.lsp.extensions'
local lsp_utils = require 'dm.plugins.lsp.utils'

-- LSP server configurations
---@type table<string, table|function>
local servers = {
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
      -- Find the first `go.mod` file starting from the current buffer path,
      -- moving upwards. This is to support Go workspaces.
      local modfile = vim.fs.find({ 'go.mod' }, {
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        upward = true,
        type = 'file',
      })[1]
      for line in io.lines(modfile) do
        if vim.startswith(line, 'module') then
          -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#local-string
          client.config.settings.gopls['local'] = vim.split(line, ' ', { plain = true })[2]
        end
      end
      client.notify(M.workspace_didChangeConfiguration, { settings = client.config.settings })
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
      filetypes = { 'json', 'jsonc' },
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

  -- https://github.com/astral-sh/ruff-lsp
  -- Install: `pipx install ruff-lsp`
  -- Settings: https://github.com/astral-sh/ruff-lsp#settings
  ruff_lsp = {
    init_options = {
      settings = {
        -- Let's use the global executable. This can be upgraded irrespective
        -- of the bundled version.
        path = { vim.fn.exepath 'ruff' },
      },
    },
    commands = {
      RuffAutofix = {
        function()
          lsp_utils
            .get_client('ruff_lsp')
            .request(vim.lsp.protocol.Methods.workspace_executeCommand, {
              command = 'ruff.applyAutofix',
              arguments = {
                { uri = vim.uri_from_bufnr(0) },
              },
            })
        end,
        description = 'Ruff: Fix all auto-fixable problems',
      },
      RuffOrganizeImports = {
        function()
          lsp_utils
            .get_client('ruff_lsp')
            .request(vim.lsp.protocol.Methods.workspace_executeCommand, {
              command = 'ruff.applyOrganizeImports',
              arguments = {
                { uri = vim.uri_from_bufnr(0) },
              },
            })
        end,
        description = 'Ruff: Format imports',
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
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          features = 'all',
          buildScripts = {
            enable = true,
          },
        },
        checkOnSave = true,
        check = {
          command = 'clippy',
        },
        inlayHints = {
          closingBraceHints = {
            enable = false,
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
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if vim.tbl_contains({ 'ruff', 'ruff-test', 'biome' }, vim.fs.basename(path)) then
        -- Disable `checkOnSave` for monorepo as it takes too long.
        -- Use `;c` or `:RustRunFlycheck` to manually check.
        client.config.settings['rust-analyzer'].checkOnSave = false
      end
      client.notify(M.workspace_didChangeConfiguration, { settings = client.config.settings })
      return true
    end,
    capabilities = {
      experimental = {
        localDocs = true,
        commands = {
          -- See: ./extensions/rust_analyzer.lua
          commands = {
            'rust-analyzer.runSingle',
            'rust-analyzer.debugSingle',
            'rust-analyzer.showReferences',
            'rust-analyzer.gotoLocation',
          },
        },
      },
    },
    commands = {
      RustRunnables = {
        function()
          extensions.rust_analyzer.runnables()
        end,
        desc = 'rust-analyzer: runnables',
      },
      RustLastRun = {
        function()
          extensions.rust_analyzer.execute_last_runnable()
        end,
        desc = 'rust-analyzer: execute last runnable',
      },
      RustViewCrateGraph = {
        function()
          extensions.rust_analyzer.view_crate_graph(false)
        end,
        desc = 'rust-analyzer: View crate graph',
      },
      RustViewCrateGraphFull = {
        function()
          extensions.rust_analyzer.view_crate_graph(true)
        end,
        desc = 'rust-analyzer: View crate graph (full)',
      },
      RustRunFlycheck = {
        function()
          extensions.rust_analyzer.run_flycheck()
        end,
        desc = 'rust-analyzer: Run Flycheck',
      },
      RustCancelFlycheck = {
        function()
          extensions.rust_analyzer.cancel_flycheck()
        end,
        desc = 'rust-analyzer: Cancel Flycheck',
      },
      RustClearFlycheck = {
        function()
          extensions.rust_analyzer.clear_flycheck()
        end,
        desc = 'rust-analyzer: Clear Flycheck',
      },
      RustExpandMacro = {
        function()
          extensions.rust_analyzer.expand_macro_recursively()
        end,
        desc = 'rust-analyzer: Expand macro recursively',
      },
      RustOpenExternalDocs = {
        function()
          extensions.rust_analyzer.open_external_docs()
        end,
        desc = 'rust-analyzer: Open external docs',
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
        hint = {
          enable = true,
          arrayIndex = 'Disable',
          paramName = 'Disable',
        },
        format = {
          enable = false,
        },
        workspace = {
          preloadFileSize = 1000,
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

return servers
