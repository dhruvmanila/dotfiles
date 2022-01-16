-- LSP server configurations
---@return table<string, table|function>
return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd
  clangd = {},

  -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
  dockerls = {},

  -- https://github.com/golang/tools/tree/master/gopls
  -- Settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
      },
    },
  },

  -- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
  -- Settings: https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
  jsonls = function()
    return {
      settings = {
        schemas = require("schemastore").json.schemas(),
      },
    }
  end,

  -- https://github.com/microsoft/pyright
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
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua
  sumneko_lua = function()
    local root = vim.loop.os_homedir() .. "/git/lua-language-server"
    local bin = root .. "/bin/macOS/lua-language-server"

    return require("lua-dev").setup {
      library = {
        plugins = false,
      },
      lspconfig = {
        cmd = { bin, "-E", root .. "/main.lua" },
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

  -- https://github.com/iamcco/vim-language-server
  vimls = {},

  -- https://github.com/redhat-developer/yaml-language-server
  -- Settings: https://github.com/redhat-developer/yaml-language-server#language-server-settings
  yamlls = {},
}
