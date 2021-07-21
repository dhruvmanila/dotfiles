local g = vim.g
local tree_cb = require("nvim-tree.config").nvim_tree_callback

-- On Ready Event for Lazy Loading to work
require("nvim-tree.events").on_nvim_tree_ready(function()
  vim.cmd "NvimTreeRefresh"
end)

g.nvim_tree_ignore = {
  ".git",
  "__pycache__",
  ".DS_Store",
  ".pyc",
  ".pyo",
  ".mypy_cache",
}

g.nvim_tree_quit_on_open = 0
g.nvim_tree_indent_markers = 1
g.nvim_tree_follow = 1
g.nvim_tree_disable_netrw = 0
g.nvim_tree_hijack_netrw = 0

-- TODO: synchronize this with lir and nnn
g.nvim_tree_bindings = {
  { key = ".", cb = tree_cb "toggle_dotfiles" },
  { key = { "l", "<CR>" }, cb = tree_cb "edit" },
  { key = "h", cb = tree_cb "close_node" },
  { key = "gh", cb = tree_cb "toggle_help" },
}

g.nvim_tree_show_icons = {
  git = 0,
  folders = 1,
  files = 1,
}

g.nvim_tree_icons = {
  git = {
    unstaged = "",
    staged = "",
    unmerged = "",
    renamed = "",
    untracked = "",
    deleted = "",
  },
  folder = {
    default = "",
    open = "",
    empty = "",
    empty_open = "",
  },
}

dm.nnoremap("<C-n>", "<Cmd>NvimTreeToggle<CR>")
