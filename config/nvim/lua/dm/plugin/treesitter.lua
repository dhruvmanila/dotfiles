local map = require("dm.utils").map

map("n", "<Leader>tp", "<Cmd>TSPlaygroundToggle<CR>")
map("n", "<Leader>th", "<Cmd>TSHighlightCapturesUnderCursor<CR>")

require("nvim-treesitter.configs").setup {
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

  highlight = {
    enable = true,
    -- Custom capture groups defined in highlights.scm
    custom_captures = {
      ["docstring"] = "TSComment",
    },
  },

  playground = {
    enable = true,
    updatetime = 25,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "<TAB>",
      scope_incremental = "grc",
      node_decremental = "<S-TAB>",
    },
  },

  textobjects = {
    select = {
      enable = true,
      -- Custom capture groups defined in textobjects.scm
      keymaps = {
        ["aC"] = "@class.outer",
        ["iC"] = "@class.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aF"] = "@call.outer",
        ["iF"] = "@call.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
  },
}
