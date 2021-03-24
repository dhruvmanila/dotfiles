-- Ref: https://github.com/kyazdani42/nvim-tree.lua
local g = vim.g
local map = vim.api.nvim_set_keymap
local utils = require('core.utils')
local tree_cb = require('nvim-tree.config').nvim_tree_callback

g.nvim_tree_ignore = {
  '.git', 
  '__pycache__',
  '.DS_Store',
  '.pyc',
  '.pyo',
  '.mypy_cache'
}

g.nvim_tree_quit_on_open   = 1
g.nvim_tree_indent_markers = 1
-- g.nvim_tree_follow         = 1
g.nvim_tree_disable_netrw  = 0
g.nvim_tree_hijack_netrw   = 0

g.nvim_tree_bindings = {
  ["."] = tree_cb("toggle_dotfiles"),
  ["l"] = tree_cb("edit"),
  ["h"] = tree_cb("close_node"),
}

g.nvim_tree_icons = {
  git = {
    unstaged  = '!',
    staged    = '+',
    untracked = '?',
  }
}

map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>', {noremap = true})
map('n', '<C-f>', '<Cmd>NvimTreeFindFile<CR>', {noremap = true})
