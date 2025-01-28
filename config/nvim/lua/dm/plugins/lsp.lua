return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'b0o/SchemaStore.nvim',
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            -- Load luvit types for `vim.uv`
            { path = '${3rd}/luv/library' },
          },
        },
      },
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local configs = require 'lspconfig.configs'

      local servers = require 'dm.lsp.servers'

      -- Setup border for the `:LspInfo` window
      require('lspconfig.ui.windows').default_options.border = dm.border

      vim
        .iter({
          'bashls',
          'cssls',
          'clangd',
          'dockerls',
          'gopls',
          'html',
          'jsonls',
          'marksman',
          'pyright',
          'ruff',
          -- 'ruff_lsp',
          'rust_analyzer',
          'lua_ls',
          'ts_ls',
        })
        :each(function(name)
          local config = servers.get(name)
          if config then
            lspconfig[name].setup(config)
          end
        end)

      if not configs.red_knot then
        configs.red_knot = {
          default_config = vim.tbl_deep_extend('keep', {
            cmd = { 'red_knot', 'server' },
          }, configs.ruff.config_def.default_config),
        }
      end
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
