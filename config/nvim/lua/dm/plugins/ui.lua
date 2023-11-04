return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '▏',
      },
      scope = {
        enabled = false,
      },
      exclude = {
        filetypes = {
          'dap-repl',
          'dashboard',
          'fugitive',
          'git',
          'log',
          'markdown',
          'txt',
        },
      },
    },
    config = function(_, opts)
      require('ibl').setup(opts)

      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.SKIP_LINE, function(_, bufnr, _, line)
        return vim.bo[bufnr].filetype == 'go' and line == ''
      end)
    end,
  },
}
