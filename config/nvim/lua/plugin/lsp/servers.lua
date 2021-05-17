-- Server configurations

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

--- This function if called immediately on startup might not have all the correct
--- paths added to the runtime if the the package manager e.g. packer loads things too late
local function get_lua_runtime()
  local result = {}
  for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
    local lua_path = string.format("%s/lua", path)
    if vim.fn.isdirectory(lua_path) > 0 then
      -- Resolve the symlinks to avoid duplication
      result[vim.loop.fs_realpath(lua_path)] = true
    end
  end

  -- This loads the `lua` files from nvim into the runtime.
  result[vim.fn.expand("$VIMRUNTIME/lua")] = true
  return result
end

-- LSP server configs are setup dynamically as they need to be generated during
-- startup so things like runtimepath for lua is correctly populated.
---@return table<string, table|function>
return {
  -- https://github.com/bash-lsp/bash-language-server
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/mattn/efm-langserver
  -- Settings: https://github.com/mattn/efm-langserver/blob/master/schema.json
  efm = {
    init_options = { documentFormatting = true },
    filetypes = { "python" },
    settings = {
      rootMarkers = { ".git/", "requirements.txt" },
      languages = {
        python = { black, isort, flake8, mypy },
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
          typeCheckingMode = "off", -- Using mypy
          -- https://github.com/microsoft/pylance-release/issues/1055
          indexing = false,
        },
      },
    },
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
  -- Settings: https://github.com/sumneko/vscode-lua/blob/master/setting/schema.json
  sumneko_lua = function()
    -- NOTE: This is the secret sauce that allows reading requires and variables
    -- between different modules in the nvim lua context
    ---@see https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8
    local path = vim.split(package.path, ";")
    table.insert(path, "lua/?.lua")
    table.insert(path, "lua/?/init.lua")
    local library = get_lua_runtime()
    return {
      cmd = {
        os.getenv("HOME")
          .. "/git/lua-language-server/bin/macOS/lua-language-server",
        "-E",
        os.getenv("HOME") .. "/git/lua-language-server/main.lua",
      },
      -- delete root from workspace to make sure we don't trigger duplicate
      -- warnings
      on_new_config = function(config, root)
        local libs = vim.deepcopy(library)
        libs[root] = nil
        config.settings.Lua.workspace.library = libs
        return config
      end,
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = path,
          },
          diagnostics = {
            enable = true,
            -- Get the language server to recognize the globals
            globals = { "vim", "use" },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = library,
            maxPreload = 1000,
            preloadFileSize = 1000,
          },
          -- Do not send telemetry data
          telemetry = { enable = false },
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
