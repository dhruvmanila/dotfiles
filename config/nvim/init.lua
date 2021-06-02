--
--          ███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
--          ████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
--          ██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
--          ██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
--          ██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
--          ╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
--
-------------------------------------------------------------------------------

--[[ High level overview

./lua/core/*.lua  (sourced using `require`)
  The core module contains all the files related to personal setup and
  configuration.

  This might include plugin specification, options, commands,
  autocommands, key bindings and more.


./lua/plugin/*.lua  (sourced by 'packer.nvim')
  This is where configuration for new style plugins live.

  They are sourced by specifying the path for each plugin in the plugin
  specification table in the `packer.use` function.


./after/plugin/*.vim
  This is where configuration for old style plugins live.

  They get auto sourced on startup. In general, the name of the file
  configures the plugin with the corresponding name.


./after/ftplugin/*.vim
  This is where all of the file type plugins lives. They are used to fine tune
  settings for a specific language.

--]]

local g = vim.g

-- Leader key is 'Space'
g.mapleader = " "

-- Enable embedded script highlighting for lua
g.vimsyn_embed = "l"

-- Default sessions directory
-- This is set here as it is accessed by Dashboard as well
g.startify_session_dir = vim.fn.stdpath("data") .. "/session"

-- Global window blend value. This will be used for the completion menu and
-- all the floating windows.
-- TODO: kitty cuts or reduce size for double width symbol
g.window_blend = 0

-- Setup neovim providers. Most of the providers are disabled by default and
-- will be enabled as the need arises.
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.python3_host_prog = "~/.neovim/py3/bin/python3"
g.node_host_prog = "/usr/local/bin/neovim-node-host"

-- Disable built-in plugins (:help standard-plugin-list)
g.loaded_gzip = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_matchit = 1
g.loaded_2html_plugin = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_tutor_mode_plugin = 1

-- Load the core files
--
-- `globals` module contains the functions which will be available in the
-- lua global table `_G`. This includes the namespace `dm` which contains
-- the lua port to vim's builtin `autocmd`, `command` and more.
require("core.globals")

-- `plugins` module contains the plugin specification for `packer.nvim`.
-- This will also automatically install packer.nvim if it is not installed.
-- A lot of plugins are lazy loaded on events, keymaps and commands to increase
-- the startuptime.
require("core.plugins")

-- `statusline` module contains the configuration for the custom statusline.
-- This includes the statusline for regular buffers, inactive buffers and
-- special buffer such as those for the plugin filetypes.
--
-- Some of the components are:
--   - Git branch
--   - LSP server name and id
--   - LSP messages as and only when they appear
--   - LSP diagnostics information
--   - LSP current function
--   - Async components includes:
--     - Python version
--     - GitHub notification count
--   - Python virtual environment name
require("core.statusline")

-- `tabline` module contains the specification for the custom tabline.
-- The file related components are displayed on the tabline instead of the
-- statusline.
--
-- Why waste the tabline region and cram everything into the statusline?
require("core.tabline")

-- Following modules, as the name suggests, are the core editor configurations.
require("core.options")
require("core.commands")
require("core.mappings")

-- This is where a lot of the automation is configured. This includes:
--   - Clearing out the commandline messages after a period of time
--   - Cursorline only in Normal mode
--   - Colorcolumn only for the current window and in Insert mode. Also,
--     avoid setting it for special buffers and set it as per the filetype.
--   - Trim trailing whitespace
-- And more...
require("core.autocmds")
