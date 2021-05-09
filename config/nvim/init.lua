--
--          ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--          ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
--          ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
--          ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
--          ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--          ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-------------------------------------------------------------------------------

--[[ High level overview

./lua/core/*.lua  (sourced using `require`)
  This is where all of the files related to initial setup lives which includes
  plugin specification, options, commands, autocommands, and key bindings.


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

-- Setup neovim providers
g.loaded_python_provider = 0
g.python3_host_prog = "~/.neovim/py3/bin/python3"
g.node_host_prog = "/usr/local/bin/neovim-node-host"

-- Disable built-in plugins
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
-- g.loaded_man             = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_tutor_mode_plugin = 1

-- Load the core files
require("core.globals")
require("core.plugins")
require("core.statusline")
require("core.tabline")
require("core.options")
require("core.commands")
require("core.autocmds")
require("core.mappings")
