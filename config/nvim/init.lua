--
--      ____     __  ___
--     / __ \   /  |/  /
--    / / / /  / /|_/ /    Dhruv Manilawala's Neovim config
--   / /_/ /  / /  / /     https://github.com/dhruvmanila
--  /_____/  /_/  /_/
--
-------------------------------------------------------------------------------

local g = vim.g

if vim.loader then
  vim.loader.enable()
end

-- Leader bindings
g.mapleader = ' '
g.maplocalleader = ' '

-- Disable Neovim providers (`:h provider`)
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_python3_provider = 0

local namespace = {
  config = {
    -- Global border style
    --
    -- See: https://en.wikipedia.org/wiki/Box-drawing_character
    ---@type 'edge'|'single'|'double'|'shadow'|'rounded'|'solid'
    border_style = 'edge',

    -- Provide VS Code like code action lightbulb.
    code_action_lightbulb = {
      enable = false,
    },

    colorscheme = {
      -- Automatically switch between light and dark color schemes based on macOS appearance.
      auto = {
        enable = true,
      },
      -- Color scheme for dark mode.
      dark = 'gruvbox_dark',
      -- Color scheme for light mode.
      light = 'gruvbox_light',
    },

    -- LSP inlay hints.
    inlay_hints = {
      enable = false,
    },
  },

  -- Constants

  -- Indicates whether Neovim is used as Kitty's scrollback buffer.
  KITTY_SCROLLBACK = vim.env.KITTY_SCROLLBACK ~= nil,

  -- System name.
  ---@type 'Darwin'|'Windows_NT'|'Linux'
  OS_UNAME = vim.uv.os_uname().sysname,

  -- Path to the home directory.
  ---@type string
  OS_HOMEDIR = assert(vim.uv.os_homedir()),

  -- Path to the current working directory.
  ---@type string
  CWD = assert(vim.uv.cwd()),
}

-- Custom global namespace.
_G.dm = dm or namespace

-- System-specific command to use for opening a path.
dm.OPEN_COMMAND = (dm.OS_UNAME == 'Darwin' and 'open')
  or (dm.OS_UNAME == 'Windows_NT' and 'start')
  or 'xdg-open'

require 'dm.globals' -- Global functions and variables
require 'dm.options' -- Neovim options

do
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
end

-- See: https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require('lazy').setup('dm.plugins', {
  change_detection = {
    notify = false,
  },
  defaults = {
    -- Disable all plugins when using Neovim as Kitty scrollback buffer.
    cond = not dm.KITTY_SCROLLBACK,
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

if dm.KITTY_SCROLLBACK then
  require 'dm.kitty'
else
  require('dm.projects').setup()
end
