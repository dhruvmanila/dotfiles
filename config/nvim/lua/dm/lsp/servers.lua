-- LSP server configurations
---@return table<string, table|function>
return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Install: `npm install --global bash-language-server`
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

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
        usePlaceholders = true,
      },
    },
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
              description = "Lua language server config file",
              fileMatch = { ".luarc.json" },
              url = "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
            },
          }, require("schemastore").json.schemas()),
        },
      },
    }
  end,

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
          typeCheckingMode = "off", -- Using mypy
        },
      },
    },
  },

  -- https://github.com/sumneko/lua-language-server
  -- Install: `brew install lua-language-server`
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
  sumneko_lua = function()
    return require("lua-dev").setup {
      library = {
        plugins = false,
      },
      lspconfig = {
        settings = {
          Lua = {
            completion = {
              -- Do NOT show contextual words, I got `cmp-buffer` for that.
              showWord = "Disable",
            },
            workspace = {
              preloadFileSize = 1000,
            },
            diagnostics = {
              globals = { "packer_plugins" },
            },
          },
        },
      },
    }
  end,

  -- https://github.com/typescript-language-server/typescript-language-server
  -- Install: `npm install --global typescript typescript-language-server`
  -- Settings: https://github.com/typescript-language-server/typescript-language-server#initializationoptions
  tsserver = {},

  -- https://github.com/iamcco/vim-language-server
  -- Install: `npm install --global vim-language-server`
  vimls = {},

  -- https://github.com/redhat-developer/yaml-language-server
  -- Install: `npm install --global yaml-language-server`
  -- Settings: https://github.com/redhat-developer/yaml-language-server#language-server-settings
  yamlls = {},
}
