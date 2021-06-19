-- Server configurations
local warn = require("dm.utils").warn

-- efm language server tool configuration
local mypy = {
  lintCommand = "mypy --show-column-numbers --follow-imports silent",
  lintFormats = {
    "%f:%l:%c: %trror: %m",
    "%f:%l:%c: %tarning: %m",
    "%f:%l:%c: %tote: %m",
  },
  lintIgnoreExitCode = true,
  lintSource = "mypy",
}

local flake8 = {
  lintCommand = "flake8 --stdin-display-name ${INPUT} -",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
  lintIgnoreExitCode = true,
  lintSource = "flake8",
}

local black = {
  formatCommand = "black -",
  formatStdin = true,
}

local isort = {
  formatCommand = "isort --profile black -",
  formatStdin = true,
}

-- LSP server configs are setup dynamically as they need to be generated during
-- startup so things like runtimepath for lua is correctly populated.
---@return table<string, table|function>
return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/mattn/efm-langserver
  -- Settings: https://github.com/mattn/efm-langserver/blob/master/schema.json
  -- efm = {
  --   init_options = { documentFormatting = true },
  --   filetypes = { "python" },
  --   settings = {
  --     rootMarkers = { ".git/", "requirements.txt" },
  --     languages = {
  --       python = { black, isort, flake8, mypy },
  --     },
  --   },
  -- },

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
      lspconfig = {
        cmd = { bin, "-E", root .. "/main.lua" },
        settings = {
          Lua = {
            workspace = {
              preloadFileSize = 1000,
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
