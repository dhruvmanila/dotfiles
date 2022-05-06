--
--          ███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
--          ████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
--          ██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
--          ██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
--          ██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
--          ╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
--
--           This is the Neovim configuration of Dhruv Manilawala
--                     https://github.com/dhruvmanila
-------------------------------------------------------------------------------
local g = vim.g

pcall(require, 'impatient')

-- Leader bindings
g.mapleader = ' '
g.maplocalleader = ' '

-- Setup neovim providers (`:h provider`)
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_python3_provider = 0

-- Disable built-in plugins (`:h standard-plugin-list`)
g.loaded_2html_plugin = 1
g.loaded_gzip = 1
g.loaded_matchit = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1

-- Disable builtin filetype detection and switch to `filetype.lua`.
g.did_load_filetypes = 0
g.do_filetype_lua = 1

-- Custom global variables for use in various parts of the config. These don't
-- have any special meaning in Neovim.

-- Global border style
---@type '"edge"'|'"single"'|'"double"'|'"shadow"'|'"rounded"'|'"solid"'
---@see https://en.wikipedia.org/wiki/Box-drawing_character
g.border_style = 'edge'

-- Operating system name
---@type "'Darwin'"|"'Linux'"|"'Windows_NT'"
g.os = vim.loop.os_uname().sysname

-- Shell command used to open URL, files, etc.
---@type "'open'"|"'xdg-open'"|"'start'"
g.open_command = (g.os == 'Darwin' and 'open')
  or (g.os == 'Linux' and 'xdg-open')
  or (g.os == 'Windows_NT' and 'start')

require 'dm.globals' -- Global functions and variables
require 'dm.plugins' -- Plugin configuration
