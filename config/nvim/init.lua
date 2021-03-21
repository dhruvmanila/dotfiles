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
  plugin specification, options, commands, autocommands, key bindings.


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
g.mapleader = ' '

-- Setup neovim providers
g.loaded_python_provider = 0
g.python3_host_prog = '~/.pyenv/versions/neovim/bin/python3'
g.node_host_prog = '/usr/local/bin/neovim-node-host'

-- Load packer.nvim files
require('core.plugins')

-- Load neovim options
require('core.options')

-- Load neovim commands
require('core.commands')

-- Load neovim autocommands
require('core.autocmds')

-- Load neovim key bindings
require('core.mappings')
