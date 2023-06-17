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

if vim.loader then
  vim.loader.enable()
end

-- Leader bindings
g.mapleader = ' '
g.maplocalleader = ' '

-- Setup neovim providers (`:h provider`)
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_python3_provider = 0

-- Custom global variables for use in various parts of the config. These don't
-- have any special meaning in Neovim.

-- Global border style
---@type 'edge'|'single'|'double'|'shadow'|'rounded'|'solid'
---@see https://en.wikipedia.org/wiki/Box-drawing_character
g.border_style = 'edge'

-- Operating system name
---@type 'Darwin'|'Linux'|'Windows_NT'
g.os = vim.loop.os_uname().sysname

-- Home directory path
---@type string
g.os_homedir = assert(vim.loop.os_homedir())

-- Shell command used to open URL, files, etc.
---@type 'open'|'xdg-open'|'start'
g.open_command = (g.os == 'Darwin' and 'open')
  or (g.os == 'Windows_NT' and 'start')
  or 'xdg-open'

-- Provide VSCode like code action lightbulb.
---@type boolean
g.lsp_code_action_lightbulb = false

require 'dm.globals' -- Global functions and variables
require 'dm.options' -- Neovim options

-- Plugins

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  vim.notify 'Installed lazy.nvim'
end
vim.opt.runtimepath:prepend(lazypath)

-- See: https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require('lazy').setup('dm.plugins', {
  change_detection = {
    notify = false,
  },
  defaults = {
    -- lazy = true,
    -- default `cond` you can use to globally disable a lot of plugins
    -- when running inside vscode for example
    -- TODO: Maybe this could be useful to me to separate VSCode config?
    -- cond = nil, ---@type boolean|fun(self:LazyPlugin):boolean|nil
  },
  dev = {
    path = '~/projects',
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        -- 'matchit',
        -- 'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  ui = {
    border = dm.border[vim.g.border_style],
  },
})

vim.cmd.colorscheme 'gruvbox'
