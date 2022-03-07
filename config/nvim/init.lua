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

pcall(require, "impatient")

-- Leader bindings
g.mapleader = " "
g.maplocalleader = " "

-- Setup neovim providers (`:h provider`)
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.python3_host_prog = "~/.neovim/.venv/bin/python3"
g.node_host_prog = "/usr/local/bin/neovim-node-host"

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
g.border_style = "edge"

require "dm.globals" -- Global functions and variables
require "dm.plugins" -- Plugin configuration
