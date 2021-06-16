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

g.mapleader = " "

-- Enable embedded script highlighting
g.vimsyn_embed = "l"

-- Enable syntax highlighting in markdown between triple backticks.
g.markdown_fenced_languages = { "bash=sh", "json", "python", "lua", "sh" }

-- Global window blend value.
-- TODO: kitty cuts or reduce size for double width symbol
g.window_blend = 0

-- Global border style.
-- Available: "edge", "single", "double", "shadow", "rounded", "solid"
g.border_style = "edge"

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

-- Globals needs to be loaded before anything else.
require "dm.globals"
