return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'b0o/SchemaStore.nvim',
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        config = true,
      },
    },
    config = function()
      -- Setup border for the `:LspInfo` window
      require('lspconfig.ui.windows').default_options.border = dm.border
    end,
  },

  {
    'DNLHC/glance.nvim',
    opts = {
      preview_win_opts = {
        relativenumber = false,
      },
      theme = {
        enable = true,
        mode = 'darken',
      },
    },
    keys = {
      { '<leader>pd', '<Cmd>Glance definitions<CR>', desc = 'LSP: Glance definition' },
      { '<leader>pr', '<Cmd>Glance references<CR>', desc = 'LSP: Glance references' },
      { '<leader>py', '<Cmd>Glance type_definitions<CR>', desc = 'LSP: Glance type definitions' },
      { '<leader>pi', '<Cmd>Glance implementations<CR>', desc = 'LSP: Glance implementations' },
    },
  },
}
