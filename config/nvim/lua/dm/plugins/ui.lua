return {
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      char = '▏',
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,
      filetype_exclude = {
        'UltestOutput',
        'UltestSummary',
        'dap-repl',
        'dashboard',
        'fugitive',
        'git',
        'gitcommit',
        'go',
        'help',
        'log',
        'lspinfo',
        'man',
        'markdown',
        'packer',
        'txt',
      },
    },
  },
}
