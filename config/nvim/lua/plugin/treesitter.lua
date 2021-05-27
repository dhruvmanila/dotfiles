-- Ref: https://github.com/nvim-treesitter/nvim-treesitter
local map = require("core.utils").map

map("n", "<Leader>tp", "<Cmd>TSPlaygroundToggle<CR>")
map("n", "<Leader>th", "<Cmd>TSHighlightCapturesUnderCursor<CR>")

require("nvim-treesitter.configs").setup({
  -- one of 'all', 'language', or a list of languages
  ensure_installed = {
    "bash",
    "c",
    "go",
    "html",
    "json",
    "lua",
    "python",
    "query",
    "regex",
    "ruby",
    "toml",
  },

  -- syntax highlighting
  highlight = {
    enable = true,
    custom_captures = {
      ["docstring"] = "TSComment",
    },
  },

  incremental_selection = {
    enable = true,
    -- TODO: useful keybindings?
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
})
