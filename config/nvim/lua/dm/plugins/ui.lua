return {
  'Bekaboo/dropbar.nvim',

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@type ibl.config
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

  {
    'rcarriga/nvim-notify',
    opts = {
      stages = 'fade',
      icons = {
        ERROR = dm.icons.error,
        WARN = dm.icons.warn,
        INFO = dm.icons.info,
        DEBUG = '',
      },
      on_open = function(winnr)
        vim.api.nvim_win_set_config(winnr, { zindex = 100 })
        vim.keymap.set('n', 'q', '<Cmd>bdelete<CR>', {
          buffer = vim.api.nvim_win_get_buf(winnr),
          nowait = true,
        })
      end,
      max_width = math.floor(vim.o.columns * 0.4),
      -- render = 'wrapped-default',
    },
  },
}
