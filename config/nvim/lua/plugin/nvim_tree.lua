-- Ref: https://github.com/kyazdani42/nvim-tree.lua
local g = vim.g
local map = vim.api.nvim_set_keymap
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
g.nvim_tree_follow         = 1
g.nvim_tree_disable_netrw  = 0
g.nvim_tree_hijack_netrw   = 0

g.nvim_tree_bindings = {
  ["."] = tree_cb("toggle_dotfiles"),
  ["l"] = tree_cb("edit"),
  ["h"] = tree_cb("close_node"),
}

g.nvim_tree_show_icons = {
  git = 0,
  folders = 1,
  files = 1,
}

g.nvim_tree_icons = {
  git = {
    unstaged  = "",
    staged    = "",
    unmerged  = "",
    renamed   = "",
    untracked = "",
    deleted   = ""
  },
  folder = {
    default    = "",
    open       = "",
    empty      = "",
    empty_open = "",
  },
}

map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>', {noremap = true})

vim.cmd [[highlight link NvimTreeIndentMarker Comment]]
