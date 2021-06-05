local g = vim.g

-- | ¦ ┆ │ ┊ │  ▏
g.indent_blankline_char = "▏"

g.indent_blankline_filetype_exclude = {
  "help",
  "man",
  "markdown",
  "lspinfo",
  "packer",
  "startify",
  "txt",
  "dashboard",
  "Outline",
}

g.indent_blankline_buftype_exclude = { "terminal", "nofile" }

g.indent_blankline_show_first_indent_level = false
g.indent_blankline_show_trailing_blankline_indent = false

-- Requires treesitter
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_current_context = false
g.indent_blankline_context_highlight = "Aqua"
