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

require("impatient").enable_profile()

-- Leader {{{
--
-- In general, it's a good idea to set this early in your config, because
-- otherwise if you have any mappings you set *before* doing this, they will be
-- set to the *old* leader.
-- }}}
g.mapleader = " "

-- Enable syntax highlighting in markdown code fences.
g.markdown_fenced_languages = {
  "applescript",
  "bash=sh",
  "json",
  "lua",
  "python",
  "sh",
  "vim",
  "viml=vim",
}

-- Setup neovim providers (`:h provider`) {{{
--
-- Most of the providers are disabled by default and will be enabled as the need
-- arises.
-- }}}
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_python_provider = 0
g.python3_host_prog = "~/.neovim/py3/bin/python3"
g.node_host_prog = "/usr/local/bin/neovim-node-host"

-- Disable built-in plugins (`:h standard-plugin-list`) {{{
--
-- Neovim does not provide the following standard plugins available in Vim:
--
--   - getscript
--   - logipat
--   - rrhelper
--
-- `vimball` is an optional plugin by default but it can be disabled with:
--
--   -- autoload/ + plugin/
--   vim.g.loaded_vimball = 1
--   vim.g.loaded_vimballPlugin = 1
-- }}}
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

-- Custom global variables for use in various parts of the config. These don't
-- have any special meaning in Neovim.

-- Global border style {{{
--
-- 'edge' is a custom border style using the unicode box drawing characters.
-- They are available in the 'Symbols for Legacy Computing' section of
-- https://en.wikipedia.org/wiki/Box-drawing_character. The rest are defined in
-- Neovim.
--
-- NOTE: This needs to be defined *before* setting the colorscheme as it uses
-- this variable to set the `NormalFloat` and `FloatBorder` highlight groups.
--
-- Available: "edge", "single", "double", "shadow", "rounded", "solid"
-- }}}
g.border_style = "edge"

-- Setup global functions and variables. {{{
--
-- Globals needs to be loaded before anything else. Most of the functions/variables
-- are available in the `dm` namespace.
--
--     `:lua print(vim.inspect(dm, { depth = 1 }))`
--
-- The rest can be accessed directly and are mostly used for debugging purposes.
-- See `./lua/dm/globals.lua` for more information.
-- }}}
require "dm.globals"
