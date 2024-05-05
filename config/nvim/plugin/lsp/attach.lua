local lsp = vim.lsp
local M = lsp.protocol.Methods

local extensions = require 'dm.lsp.extensions'

-- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or dm.log.get_level())
require('vim.lsp.log').set_format_func(vim.inspect)

-- Set the default options for all LSP floating windows.
--   - Default border according to `dm.config.border_style`
--   - Map 'q' to quit the floating window
do
  local default_open_floating_preview = lsp.util.open_floating_preview

  ---@param contents table
  ---@param syntax string
  ---@param opts vim.lsp.util.open_floating_preview.Opts
  ---@return integer
  ---@return integer
  ---@diagnostic disable-next-line: duplicate-set-field
  lsp.util.open_floating_preview = function(contents, syntax, opts)
    opts = vim.tbl_deep_extend('force', opts, {
      border = dm.border,
      max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
      max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
    })
    local bufnr, winnr = default_open_floating_preview(contents, syntax, opts)
    vim.keymap.set('n', 'q', '<Cmd>bdelete<CR>', { buffer = bufnr, nowait = true })
    -- As per `:h 'showbreak'`, the value should be a literal "NONE".
    vim.wo[winnr].showbreak = 'NONE'
    return bufnr, winnr
  end
end

-- Setup the buffer local mappings for the LSP client.
---@param client vim.lsp.Client
---@param bufnr number
local function setup_mappings(client, bufnr)
  local mappings = {
    { 'n', 'gd', lsp.buf.definition, capability = M.textDocument_definition },
    { 'n', 'gD', lsp.buf.declaration, capability = M.textDocument_declaration },
    { 'n', 'gy', lsp.buf.type_definition, capability = M.textDocument_typeDefinition },
    { 'n', 'gi', lsp.buf.implementation, capability = M.textDocument_implementation },
    { 'n', '<leader>rn', lsp.buf.rename, capability = M.textDocument_rename },
    { { 'n', 'x' }, '<leader>ca', lsp.buf.code_action, capability = M.textDocument_codeAction },
    { 'n', '<leader>cl', lsp.codelens.run, capability = M.textDocument_codeLens },
  }

  vim.iter(mappings):each(function(m)
    if client.supports_method(m.capability) then
      vim.keymap.set(m[1], m[2], m[3], { buffer = bufnr, desc = ('LSP: %s'):format(m.capability) })
    end
  end)
end

-- Setup the buffer local autocmds for the LSP client.
---@param client vim.lsp.Client
---@param bufnr number
local function setup_autocmds(client, bufnr)
  if client.supports_method(M.textDocument_documentHighlight) then
    local group = vim.api.nvim_create_augroup('dm__lsp_document_highlight', { clear = false })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
    vim.api.nvim_create_autocmd('CursorHold', {
      group = group,
      buffer = bufnr,
      callback = lsp.buf.document_highlight,
      desc = 'LSP: Document highlight',
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = group,
      buffer = bufnr,
      callback = lsp.buf.clear_references,
      desc = 'LSP: Clear references',
    })
  end

  if
    dm.config.code_action_lightbulb.enable and client.supports_method(M.textDocument_codeAction)
  then
    local group = vim.api.nvim_create_augroup('dm__lsp_code_action_lightbulb', { clear = false })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
    vim.api.nvim_create_autocmd('CursorHold', {
      group = group,
      buffer = bufnr,
      callback = require('dm.lsp.code_action').listener,
      desc = 'LSP: Code action (bulb)',
    })
  end

  if client.supports_method(M.textDocument_codeLens) then
    local group = vim.api.nvim_create_augroup('dm__lsp_code_lens_refresh', { clear = false })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
    vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
      group = group,
      buffer = bufnr,
      callback = function()
        -- TODO: Check if this is correct
        -- TODO: It shows a lot of notifications if client doesn't support it, so silence them via vimscript
        lsp.codelens.refresh { bufnr = bufnr }
      end,
      desc = 'LSP: Refresh codelens',
    })
  end

  if dm.config.inlay_hints.enable and client.supports_method(M.textDocument_inlayHint) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- Setup the buffer local mappings and autocmds for the LSP client.
---@param client vim.lsp.Client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_mappings(client, bufnr)
  setup_autocmds(client, bufnr)

  if client.name == 'pyright' then
    extensions.pyright.on_attach(bufnr)
  end

  if client.name == 'ruff_lsp' then
    client.server_capabilities.hoverProvider = false
    extensions.ruff_lsp.on_attach(bufnr)
  end

  if client.name == 'rust_analyzer' then
    extensions.rust_analyzer.on_attach(bufnr)
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('dm__lsp_attach', { clear = true }),
  callback = function(args)
    local client = lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    on_attach(client, args.buf)
  end,
  desc = 'LSP: Setup language server',
})
