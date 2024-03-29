return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'b0o/SchemaStore.nvim',
      'folke/neodev.nvim',
    },
    config = function()
      local lsp = vim.lsp
      local M = vim.lsp.protocol.Methods
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
          local bufnr, winnr = default_open_floating_preview(contents, syntax, opts)
          keymap.set('n', 'q', '<Cmd>bdelete<CR>', {
            buffer = bufnr,
            nowait = true,
          })
          -- As per `:h 'showbreak'`, the value should be a literal "NONE".
          vim.wo[winnr].showbreak = 'NONE'
          vim.wo[winnr].conceallevel = 0
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
      ---@param client lsp.Client
      ---@param bufnr number
      local function on_attach(client, bufnr)
        -- Wrapper around `client.supports_method`.
        ---@param method string
        ---@return boolean
        local function supports_method(method)
          return client.supports_method(method, { bufnr = bufnr })
        end

        if client.name == 'ruff_lsp' then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
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
          keymap.set('n', '<leader>rm', rust_analyzer.expand_macro_recursively, {
            buffer = bufnr,
            desc = 'LSP (rust-analyzer): Expand macro recursively',
          })
          keymap.set('n', '<leader>rd', rust_analyzer.open_external_docs, {
            buffer = bufnr,
            desc = 'LSP (rust-analyzer): Open external docs',
          })
        end

        if supports_method(M.textDocument_hover) then
          keymap.set('n', 'K', lsp.buf.hover, {
            buffer = bufnr,
            desc = 'LSP: Hover',
          })
        end

        if supports_method(M.textDocument_definition) then
          keymap.set('n', 'gd', lsp.buf.definition, {
            buffer = bufnr,
            desc = 'LSP: Goto definition',
          })
        end

        if supports_method(M.textDocument_declaration) then
          keymap.set('n', 'gD', lsp.buf.declaration, {
            buffer = bufnr,
            desc = 'LSP: Goto declaration',
          })
        end

        if supports_method(M.textDocument_typeDefinition) then
          keymap.set('n', 'gy', lsp.buf.type_definition, {
            buffer = bufnr,
            desc = 'LSP: Goto type definition',
          })
        end

        if supports_method(M.textDocument_implementation) then
          keymap.set('n', 'gi', lsp.buf.implementation, {
            buffer = bufnr,
            desc = 'LSP: Goto implementation',
          })
        end

        if supports_method(M.textDocument_references) then
          keymap.set('n', 'gr', lsp.buf.references, {
            buffer = bufnr,
            desc = 'LSP: Goto references',
          })
        end

        if supports_method(M.textDocument_rename) then
          keymap.set('n', '<leader>rn', lsp.buf.rename, {
            buffer = bufnr,
            desc = 'LSP: Rename',
          })
        end

        if supports_method(M.textDocument_signatureHelp) then
          keymap.set('n', '<C-s>', lsp.buf.signature_help, {
            buffer = bufnr,
            desc = 'LSP: Signature help',
          })
        end

        -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
        if supports_method(M.textDocument_documentHighlight) then
          local lsp_document_highlight_group =
            vim.api.nvim_create_augroup('dm__lsp_document_highlight', {
              clear = false,
            })
          vim.api.nvim_clear_autocmds {
            buffer = bufnr,
            group = lsp_document_highlight_group,
          }
          vim.api.nvim_create_autocmd('CursorHold', {
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

        if supports_method(M.textDocument_codeAction) then
          if dm.config.code_action_lightbulb.enable then
            local lsp_code_action_group =
              vim.api.nvim_create_augroup('dm__lsp_code_action_lightbulb', {
                clear = false,
              })
            vim.api.nvim_clear_autocmds {
              buffer = bufnr,
              group = lsp_code_action_group,
            }
            vim.api.nvim_create_autocmd('CursorHold', {
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

        if supports_method(M.textDocument_codeLens) then
          local lsp_code_lens_group = vim.api.nvim_create_augroup('dm__lsp_code_lens_refresh', {
            clear = false,
          })
          vim.api.nvim_clear_autocmds {
            buffer = bufnr,
            group = lsp_code_lens_group,
          }
          vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
            group = lsp_code_lens_group,
            buffer = bufnr,
            callback = lsp.codelens.refresh,
            desc = 'LSP: Refresh codelens',
          })
          keymap.set('n', '<leader>cl', lsp.codelens.run, {
            buffer = bufnr,
            desc = 'LSP: Run codelens for current line',
          })
        end

        if dm.config.inlay_hints.enable and supports_method(M.textDocument_inlayHint) then
          vim.lsp.inlay_hint.enable(bufnr, true)
          -- TODO: temporarily disable inlay hints in insert mode due to
          -- https://github.com/neovim/neovim/issues/24075
          local lsp_inlay_hint_group = vim.api.nvim_create_augroup('dm__lsp_inlay_hint', {
            clear = false,
          })
          vim.api.nvim_clear_autocmds {
            buffer = bufnr,
            group = lsp_inlay_hint_group,
          }
          vim.api.nvim_create_autocmd('InsertEnter', {
            group = lsp_inlay_hint_group,
            buffer = bufnr,
            callback = function()
              vim.lsp.inlay_hint.enable(bufnr, false)
            end,
            desc = 'LSP: Disable inlay hints',
          })
          vim.api.nvim_create_autocmd('InsertLeave', {
            group = lsp_inlay_hint_group,
            buffer = bufnr,
            callback = function()
              vim.lsp.inlay_hint.enable(bufnr, true)
            end,
            desc = 'LSP: Enable inlay hints',
          })
        end
      end

      -- https://github.com/folke/neodev.nvim#%EF%B8%8F-configuration
      require('neodev').setup {
        library = {
          plugins = false,
        },
      }

      do
        -- Define default client capabilities.
        --
        -- References:
        -- * https://github.com/hrsh7th/cmp-nvim-lsp#setup
        -- * https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#completionClientCapabilities
        local capabilities = vim.tbl_deep_extend(
          'force',
          vim.lsp.protocol.make_client_capabilities(),
          -- `nvim-cmp` supports additional completion capabilities, so broadcast that to servers.
          require('cmp_nvim_lsp').default_capabilities(),
          {
            workspace = {
              -- PERF: didChangeWatchedFiles is too slow.
              -- TODO: Remove this when https://github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed.
              didChangeWatchedFiles = {
                dynamicRegistration = false,
              },
            },
          }
        )

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
              debounce_text_changes = 300,
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
