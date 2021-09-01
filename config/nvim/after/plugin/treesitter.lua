local nnoremap = dm.nnoremap

nnoremap("<Leader>tp", "<Cmd>TSPlaygroundToggle<CR>")
nnoremap("<Leader>th", "<Cmd>TSHighlightCapturesUnderCursor<CR>")

require("nvim-treesitter.configs").setup {
  -- one of 'all', 'language', or a list of languages
  ensure_installed = {
    "bash",
    "c",
    "comment",
    "cpp",
    "css",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "python",
    "query",
    "regex",
    "ruby",
    "toml",
    "yaml",
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
      node_incremental = "<Tab>",
      scope_incremental = "<C-s>",
      node_decremental = "<S-Tab>",
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
        ["ao"] = "@loop.outer",
        ["io"] = "@loop.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },

    swap = {
      enable = true,
      swap_next = {
        ["]a"] = "@parameter.inner",
      },
      swap_previous = {
        ["[a"] = "@parameter.inner",
      },
    },

    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
    },
  },
}
