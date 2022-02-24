vim.keymap.set("n", "<Leader>tp", "<Cmd>TSPlaygroundToggle<CR>")
vim.keymap.set("n", "<Leader>th", "<Cmd>TSHighlightCapturesUnderCursor<CR>")

require("nvim-treesitter.configs").setup {
  -- one of 'all', 'maintained', or a list of languages
  ensure_installed = {
    "bash",
    "c",
    "cmake",
    "comment",
    "dockerfile",
    "go",
    "gomod",
    "gowork",
    "hcl",
    "javascript",
    "json",
    "jsonc",
    "lua",
    "make",
    "markdown",
    "python",
    "query",
    "rust",
    "toml",
    "typescript",
    "vim",
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
      init_selection = "gn",
      node_incremental = "<C-n>",
      scope_incremental = "<C-s>",
      node_decremental = "<C-p>",
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
