local g = vim.g

g.indent_blankline_debug = false

-- | ¦ ┆ │ ┊ │  ▏
g.indent_blankline_char = "▏"

g.indent_blankline_filetype_exclude = {
  "help",
  "man",
  "markdown",
  "lspinfo",
  "packer",
  "startify",
  "text",
  "dashboard",
  "fugitive",
  "log",
  "gitcommit",
}

g.indent_blankline_buftype_exclude = { "terminal", "nofile" }

g.indent_blankline_show_first_indent_level = false
g.indent_blankline_show_trailing_blankline_indent = false

-- Requires treesitter
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_current_context = true
g.indent_blankline_context_highlight = "Aqua"

g.indent_blankline_context_patterns = {
  "class",
  "function",
  "method",
  "block",
  "^if",
  "^table",
  "if_statement",
  "return_statement",
  "while",
  "for",
}
