local M = vim.lsp.protocol.Methods

-- LSP server configurations
---@type table<string, table|function>
local servers = {
  -- https://github.com/bash-lsp/bash-language-server
  -- Install: `npm install --global bash-language-server`
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {
    settings = {
      bashIde = {
        shfmt = {
          binaryNextLine = true,
          caseIndent = true,
          spaceRedirects = true,
        },
      },
    },
  },

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
        disableOrganizeImports = true, -- Using Ruff's import organizer
      },
    },
  },

  -- https://github.com/astral-sh/ruff
  -- Install: `pipx install ruff`
  ruff = {
    trace = 'messages',
    init_options = {
      settings = {
        logLevel = 'debug',
        logFile = vim.fn.stdpath 'log' .. '/lsp.ruff.log',
      },
    },
  },

  -- https://github.com/astral-sh/ruff-lsp
  -- Install: `pipx install ruff-lsp`
  -- Settings: https://github.com/astral-sh/ruff-lsp#settings
  ruff_lsp = {
    init_options = {
      settings = {
        path = { vim.fn.exepath 'ruff' },
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
      -- See: ./extensions/rust_analyzer.lua
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

-- Overrides for language server capabilities. These are applied to all servers.
local capability_overrides = {
  workspace = {
    -- PERF: didChangeWatchedFiles is too slow.
    -- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
    didChangeWatchedFiles = {
      dynamicRegistration = false,
    },
  },
}

-- Returns the configuration for the given language server, `nil` if not found.
---@param name string
---@return table?
local function get(name)
  local config = servers[name]
  if not config then
    vim.notify_once('No LSP configuration found for ' .. name, vim.log.levels.WARN)
    return
  end
  if type(config) == 'function' then
    config = config()
  end
  local cmp_nvim_capabilities = {}
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    cmp_nvim_capabilities = cmp_nvim_lsp.default_capabilities()
  end
  config.capabilities = vim.tbl_deep_extend(
    'force',
    config.capabilities or {},
    cmp_nvim_capabilities,
    capability_overrides
  )
  return config
end

return { get = get }
