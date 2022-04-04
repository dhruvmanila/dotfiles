local g = vim.g

g.indent_blankline_char = '▏'

g.indent_blankline_filetype_exclude = {
  'UltestOutput',
  'UltestSummary',
  'dap-repl',
  'dashboard',
  'fugitive',
  'git',
  'gitcommit',
  'help',
  'log',
  'lspinfo',
  'man',
  'markdown',
  'packer',
  'txt',
}

g.indent_blankline_buftype_exclude = {
  'nofile',
  'terminal',
}

-- Do not display the indentation level in the first column.
g.indent_blankline_show_first_indent_level = false

-- Do not display a trailing indentation guide on blank lines.
g.indent_blankline_show_trailing_blankline_indent = false
