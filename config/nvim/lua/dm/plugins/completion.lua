return {
  {
    'saghen/blink.cmp',
    version = '1.*', -- Use a release tag to download pre-built binaries
    dependencies = {
      'xzbdmw/colorful-menu.nvim',
      'rafamadriz/friendly-snippets',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
      },
      appearance = {
        kind_icons = dm.icons.lsp_kind,
      },
      completion = {
        documentation = {
          -- auto_show = true,
          -- auto_show_delay_ms = 500,
          window = {
            border = dm.border,
          },
        },
        menu = {
          draw = {
            -- We don't need 'label_description' now because 'label' and 'label_description' are
            -- already combined together in 'label' by `colorful-menu.nvim`.
            columns = {
              { 'kind_icon' },
              { 'label', gap = 1 },
            },
            components = {
              label = {
                text = function(ctx)
                  return require('colorful-menu').blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require('colorful-menu').blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },
      cmdline = {
        -- TODO: Enable this
        enabled = false,
      },
    },
  },

  {
    'github/copilot.vim',
    event = 'InsertEnter',
    dependencies = { 'blink.cmp' },
  },
}
