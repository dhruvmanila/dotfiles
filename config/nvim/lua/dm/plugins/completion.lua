return {
  {
    'saghen/blink.cmp',
    version = '1.*', -- Use a release tag to download pre-built binaries
    dependencies = {
      'xzbdmw/colorful-menu.nvim',
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
          -- Use `<leader><space>` to toggle the documentation window manually.
          -- auto_show = true,
          -- auto_show_delay_ms = 500,
          window = {
            border = dm.border,
          },
        },
      },
      cmdline = {
        -- TODO: Enable this
        enabled = false,
      },
      sources = {
        min_keyword_length = function()
          local node = vim.treesitter.get_node()
          if
            (node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()))
            or vim.bo.filetype == 'markdown'
          then
            return 3
          else
            return 0
          end
        end,
        providers = {
          snippets = {
            should_show_items = function(ctx)
              -- Hide snippets after trigger character
              return ctx.trigger.initial_kind ~= 'trigger_character'
            end,
          },
        },
      },
    },
  },

  {
    'github/copilot.vim',
    event = 'InsertEnter',
    dependencies = { 'blink.cmp' },
    init = function()
      vim.g.copilot_filetypes = {
        ledger = false,
      }
    end,
  },
}
