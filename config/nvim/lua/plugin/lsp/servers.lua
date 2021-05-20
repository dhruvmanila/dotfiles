-- Server configurations
local warn = require("core.utils").warn

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

-- Neovim runtime libs to help the Lua Language Server.
-- NOTE: If the Neovim config directory is a symlink to the dotfiles directory,
-- then include the dotfiles directory instead.
---@type string[]
local neovim_runtime_lib = {
  "$VIMRUNTIME/lua", -- runtime
  "~/dotfiles", -- config
  "~/.local/share/nvim/site/pack/packer/opt/*", -- opt plugins
  "~/.local/share/nvim/site/pack/packer/start/*", -- start plugins
}

-- Return the Neovim runtime paths to help the language server.
---@return table<string, boolean>
local function get_lua_runtime()
  local library = {}
  for _, lib in ipairs(neovim_runtime_lib) do
    for _, path in ipairs(vim.fn.expand(lib, false, true)) do
      library[vim.loop.fs_realpath(path)] = true
    end
  end
  return library
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

  -- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
  -- Settings: https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
  jsonls = function()
    local vscode
    local stable = "/Applications/Visual Studio Code.app"
    local insider = "/Applications/Visual Studio Code - Insiders.app"

    -- Default to insider if available
    if vim.fn.isdirectory(insider) > 0 then
      vscode = insider
    elseif vim.fn.isdirectory(stable) > 0 then
      vscode = stable
    else
      warn("[LSP] Visual Studio Code not found, defaulting to npm installed server")
      return {}
    end

    return {
      cmd = {
        "node",
        vscode
          .. "/Contents/Resources/app/extensions/json-language-features/server/dist/node/jsonServerMain.js",
        "--stdio",
      },
    }
  end,

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
    local home = vim.loop.os_homedir()

    return {
      cmd = {
        home .. "/git/lua-language-server/bin/macOS/lua-language-server",
        "-E",
        home .. "/git/lua-language-server/main.lua",
      },

      -- Delete the root directory from workspace to make sure we don't
      -- trigger duplicate warnings.
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
