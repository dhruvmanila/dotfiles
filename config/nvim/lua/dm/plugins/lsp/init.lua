return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'b0o/SchemaStore.nvim',
      'folke/neodev.nvim',
    },
    config = function()
      local lsp = vim.lsp
      local keymap = vim.keymap

      local lspconfig = require 'lspconfig'

      local rust_analyzer = require 'dm.plugins.lsp.extensions.rust_analyzer'
      local servers = require 'dm.plugins.lsp.servers'

      require 'dm.plugins.lsp.handlers'
      require 'dm.plugins.lsp.progress'

      require('lspconfig.ui.windows').default_options.border = dm.border

      -- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
      lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or dm.current_log_level)
      require('vim.lsp.log').set_format_func(vim.inspect)

      -- Set the default options for all LSP floating windows.
      --   - Default border according to `vim.g.border_style`
      --   - 'q' to quit with `nowait = true`
      do
        local default_open_floating_preview = lsp.util.open_floating_preview

        ---@diagnostic disable-next-line: duplicate-set-field
        lsp.util.open_floating_preview = function(contents, syntax, opts)
          opts = vim.tbl_deep_extend('force', opts, {
            border = dm.border,
            max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
            max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
          })
          local bufnr, winnr =
            default_open_floating_preview(contents, syntax, opts)
          keymap.set('n', 'q', '<Cmd>bdelete<CR>', {
            buffer = bufnr,
            nowait = true,
          })
          -- As per `:h 'showbreak'`, the value should be a literal "NONE".
          vim.api.nvim_set_option_value('showbreak', 'NONE', {
            scope = 'local',
            win = winnr,
          })
          return bufnr, winnr
        end
      end

      -- The main `on_attach` function to be called by each of the language server
      -- to setup the required keybindings and functionalities provided by other
      -- plugins.
      --
      -- This function needs to be passed to every language server. If a language
      -- server requires either more config or less, it should also be done in this
      -- function using the `filetype` conditions.
      ---@param client table
      ---@param bufnr number
      local function on_attach(client, bufnr)
        local capabilities = client.server_capabilities

        if client.name == 'ruff_lsp' then
          -- Disable hover in favor of Pyright
          capabilities.hoverProvider = false
        end

        if client.name == 'rust_analyzer' then
          keymap.set('n', '<leader>rr', rust_analyzer.runnables, {
            buffer = bufnr,
            desc = 'LSP (rust-analyzer): Runnables',
          })
          keymap.set('n', '<leader>rl', rust_analyzer.execute_last_runnable, {
            buffer = bufnr,
            desc = 'LSP (rust-analyzer): Execute last runnable',
          })
        end

        if capabilities.hoverProvider then
          keymap.set('n', 'K', lsp.buf.hover, {
            buffer = bufnr,
            desc = 'LSP: Hover',
          })
        end

        if capabilities.definitionProvider then
          keymap.set('n', 'gd', lsp.buf.definition, {
            buffer = bufnr,
            desc = 'LSP: Goto definition',
          })
        end

        if capabilities.declarationProvider then
          keymap.set('n', 'gD', lsp.buf.declaration, {
            buffer = bufnr,
            desc = 'LSP: Goto declaration',
          })
        end

        if capabilities.typeDefinitionProvider then
          keymap.set('n', 'gy', lsp.buf.type_definition, {
            buffer = bufnr,
            desc = 'LSP: Goto type definition',
          })
        end

        if capabilities.implementationProvider then
          keymap.set('n', 'gi', lsp.buf.implementation, {
            buffer = bufnr,
            desc = 'LSP: Goto implementation',
          })
        end

        if capabilities.referencesProvider then
          keymap.set('n', 'gr', lsp.buf.references, {
            buffer = bufnr,
            desc = 'LSP: Goto references',
          })
        end

        if capabilities.renameProvider then
          keymap.set('n', '<leader>rn', lsp.buf.rename, {
            buffer = bufnr,
            desc = 'LSP: Rename',
          })
        end

        if capabilities.signatureHelpProvider then
          keymap.set('n', '<C-s>', lsp.buf.signature_help, {
            buffer = bufnr,
            desc = 'LSP: Signature help',
          })
        end

        -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
        if capabilities.documentHighlightProvider then
          local lsp_document_highlight_group =
            vim.api.nvim_create_augroup('dm__lsp_document_highlight', {
              clear = false,
            })
          vim.api.nvim_clear_autocmds {
            buffer = bufnr,
            group = lsp_document_highlight_group,
          }
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = lsp_document_highlight_group,
            buffer = bufnr,
            callback = lsp.buf.document_highlight,
            desc = 'LSP: Document highlight',
          })
          vim.api.nvim_create_autocmd('CursorMoved', {
            group = lsp_document_highlight_group,
            buffer = bufnr,
            callback = lsp.buf.clear_references,
            desc = 'LSP: Clear references',
          })
        end

        if capabilities.codeActionProvider then
          if dm.config.code_action_lightbulb.enable then
            local lsp_code_action_group =
              vim.api.nvim_create_augroup('dm__lsp_code_action_lightbulb', {
                clear = false,
              })
            vim.api.nvim_clear_autocmds {
              buffer = bufnr,
              group = lsp_code_action_group,
            }
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = lsp_code_action_group,
              buffer = bufnr,
              callback = require('dm.plugins.lsp.code_action').listener,
              desc = 'LSP: Code action (bulb)',
            })
          end

          keymap.set({ 'n', 'x' }, '<leader>ca', lsp.buf.code_action, {
            buffer = bufnr,
            desc = 'LSP: Code action',
          })
        end

        if capabilities.codeLensProvider then
          local lsp_code_lens_group =
            vim.api.nvim_create_augroup('dm__lsp_code_lens_refresh', {
              clear = false,
            })
          vim.api.nvim_clear_autocmds {
            buffer = bufnr,
            group = lsp_code_lens_group,
          }
          vim.api.nvim_create_autocmd(
            { 'BufEnter', 'InsertLeave', 'BufWritePost' },
            {
              group = lsp_code_lens_group,
              buffer = bufnr,
              callback = lsp.codelens.refresh,
              desc = 'LSP: Refresh codelens',
            }
          )
          keymap.set('n', '<leader>cl', lsp.codelens.run, {
            buffer = bufnr,
            desc = 'LSP: Run codelens for current line',
          })
        end

        vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
      end

      -- https://github.com/folke/neodev.nvim#%EF%B8%8F-configuration
      require('neodev').setup {
        library = {
          plugins = false,
        },
      }

      do
        -- Define default client capabilities.
        ---@see https://github.com/hrsh7th/cmp-nvim-lsp#setup
        ---@see https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#completionClientCapabilities
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Setting up the servers with the provided configuration and additional
        -- capabilities.
        for server, config in pairs(servers) do
          if type(config) == 'function' then
            config = config()
          end
          config = vim.tbl_deep_extend('keep', config, {
            on_attach = on_attach,
            capabilities = capabilities,
            flags = {
              debounce_text_changes = 500,
            },
          })
          lspconfig[server].setup(config)
        end
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
      {
        '<leader>pd',
        '<Cmd>Glance definitions<CR>',
        desc = 'LSP: Glance definition',
      },
      {
        '<leader>pr',
        '<Cmd>Glance references<CR>',
        desc = 'LSP: Glance references',
      },
      {
        '<leader>py',
        '<Cmd>Glance type_definitions<CR>',
        desc = 'LSP: Glance type definitions',
      },
      {
        '<leader>pi',
        '<Cmd>Glance implementations<CR>',
        desc = 'LSP: Glance implementations',
      },
    },
  },
}
