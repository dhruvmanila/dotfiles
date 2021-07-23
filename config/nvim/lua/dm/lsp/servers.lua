-- LSP server configurations
---@return table<string, table|function>
return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd
  clangd = {},

  -- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
  -- Settings: https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
  jsonls = {},

  -- https://github.com/microsoft/pyright
  -- Settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true, -- Using isort
      },
      python = {
        venvPath = os.getenv "HOME" .. "/.pyenv",
        analysis = {
          typeCheckingMode = "off", -- Using mypy
        },
      },
    },
  },

  -- https://github.com/sumneko/lua-language-server
  -- Settings: https://github.com/sumneko/vscode-lua/blob/master/setting/schema.json
  sumneko_lua = function()
    local home = vim.loop.os_homedir()
    local root = home .. "/git/lua-language-server"
    local bin = root .. "/bin/macOS/lua-language-server"

    return require("lua-dev").setup {
      library = {
        plugins = { "telescope.nvim", "plenary.nvim" },
      },
      lspconfig = {
        cmd = { bin, "-E", root .. "/main.lua" },
        settings = {
          Lua = {
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
