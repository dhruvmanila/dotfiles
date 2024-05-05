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

-- Operating system name
---@type 'Darwin'|'Linux'|'Windows_NT'
g.os = vim.uv.os_uname().sysname

-- Home directory path
---@type string
g.os_homedir = assert(vim.uv.os_homedir())

-- Shell command used to open URL, files, etc.
---@type 'open'|'xdg-open'|'start'
g.open_command = (g.os == 'Darwin' and 'open') or (g.os == 'Windows_NT' and 'start') or 'xdg-open'

local namespace = {
  config = {
    -- Global border style
    --
    -- See: https://en.wikipedia.org/wiki/Box-drawing_character
    ---@type 'edge'|'single'|'double'|'shadow'|'rounded'|'solid'
    border_style = 'edge',

    colorscheme = {
      -- Automatically switch between light and dark color schemes based on macOS appearance.
      auto = {
        enable = true,
      },

      -- Dark color scheme
      dark = 'gruvbox_dark',

      -- Light color scheme
      light = 'gruvbox_light',
    },

    -- Provide VSCode like code action lightbulb.
    code_action_lightbulb = {
      enable = false,
    },

    -- LSP inlay hints.
    inlay_hints = {
      enable = true,
    },
  },

  -- Indicates whether Neovim is used as Kitty's scrollback buffer.
  kitty_scrollback = vim.env.KITTY_SCROLLBACK ~= nil,
}

-- Custom global namespace.
_G.dm = dm or namespace

require 'dm.globals' -- Global functions and variables
require 'dm.options' -- Neovim options

-- Plugins

---@diagnostic disable-next-line: param-type-mismatch 'data' always return a `string`
local lazypath = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy', 'lazy.nvim')
if not vim.uv.fs_stat(lazypath) then
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
    -- Disable all plugins when using Neovim as Kitty scrollback buffer.
    cond = not dm.kitty_scrollback,
  },
  dev = {
    path = '~/projects',
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  ui = {
    border = dm.border,
  },
})

-- Default to a dark color scheme.
vim.cmd.colorscheme(dm.config.colorscheme.dark)

if dm.config.colorscheme.auto.enable then
  require('dm.themes.auto').enable()
end

if dm.kitty_scrollback then
  require 'dm.kitty'
end
