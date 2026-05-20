return {
  {
    'romus204/tree-sitter-manager.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = 'TSManager',
    opts = {
      ensure_installed = {
        'beancount',
        'go',
        'gomod',
        'gowork',
        'json',
        'python',
        'rust',
        'toml',
        'yaml',
      },
      auto_install = false,
      highlight = false,
      border = dm.border,
    },
    config = function(_, opts)
      require('tree-sitter-manager').setup(opts)

      vim.treesitter.language.register('json', 'jsonc')

      local function start_treesitter(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end

        local ok, loaded = pcall(vim.treesitter.language.add, lang)
        if not ok or not loaded then
          return
        end

        pcall(vim.treesitter.start, args.buf, lang)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('dm__treesitter_highlight', { clear = true }),
        pattern = {
          'beancount',
          'c',
          'go',
          'gomod',
          'gowork',
          'help',
          'json',
          'jsonc',
          'lua',
          'markdown',
          'python',
          'query',
          'rust',
          'toml',
          'vim',
          'yaml',
        },
        callback = start_treesitter,
        desc = 'Start treesitter highlighting when a parser is available',
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      -- I can enable this only when my laptop is connected to the monitor using the following
      -- command:
      --
      --   $ system_profiler SPDisplaysDataType | grep -c Resolution
      --
      -- This will output `n` which is the total number of displays including the builtin display.
      enable = false,
      mode = 'cursor',
      separator = '─',
      max_lines = 3,
      multiline_threshold = 1,
    },
    init = function()
      vim.keymap.set('n', '<leader>tc', '<Cmd>TSContext toggle<CR>', {
        desc = 'Toggle treesitter context',
      })
    end,
  },
}
