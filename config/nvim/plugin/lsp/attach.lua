if vim.g.vscode then
  return
end

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

---@param client vim.lsp.Client
---@return function
local function create_file_renamer(client)
  return function()
    local old_fname = vim.api.nvim_buf_get_name(0)
    vim.ui.input({ prompt = 'New file name:' }, function(name)
      if name == nil then
        return
      end
      local new_fname = ('%s/%s'):format(vim.fs.dirname(old_fname), name)
      local params = {
        files = {
          { oldUri = 'file://' .. old_fname, newUri = 'file://' .. new_fname },
        },
      }
      ---@diagnostic disable-next-line: missing-parameter `bufnr` is optional
      local response = client.request_sync(M.workspace_willRenameFiles, params, 1000)
      if not response then
        dm.log.warn('No response from %s client for %s', client.name, M.workspace_willRenameFiles)
        return
      end
      if response.err then
        dm.log.error('Failed to rename %s to %s', old_fname, new_fname)
      else
        vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
        vim.lsp.util.rename(old_fname, new_fname)
      end
    end)
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
    { 'n', 'gr', lsp.buf.references, capability = M.textDocument_references },
    { 'n', '<leader>rn', lsp.buf.rename, capability = M.textDocument_rename },
    { { 'n', 'x' }, '<leader>ca', lsp.buf.code_action, capability = M.textDocument_codeAction },
    { 'n', '<leader>cl', lsp.codelens.run, capability = M.textDocument_codeLens },
    { 'i', '<C-s>', lsp.buf.signature_help, capability = M.textDocument_signatureHelp },
  }

  vim.iter(mappings):each(function(m)
    if client.supports_method(m.capability) then
      vim.keymap.set(m[1], m[2], m[3], { buffer = bufnr, desc = ('lsp: %s'):format(m.capability) })
    end
  end)

  if client.supports_method(M.textDocument_inlayHint) then
    vim.keymap.set('n', '<leader>ih', function()
      local is_enabled = lsp.inlay_hint.is_enabled { bufnr = bufnr }
      lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
    end, { desc = 'lsp: toggle [i]nlay [h]int for buffer' })

    vim.keymap.set('n', '<leader>iH', function()
      local is_enabled = lsp.inlay_hint.is_enabled()
      lsp.inlay_hint.enable(not is_enabled)
    end, { desc = 'lsp: toggle [i]nlay [H]int globally' })
  end

  if client.supports_method(M.workspace_willRenameFiles) then
    vim.keymap.set('n', '<leader>rf', create_file_renamer(client), { desc = 'lsp: rename file' })
  end
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
      desc = 'lsp: document highlight',
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = group,
      buffer = bufnr,
      callback = lsp.buf.clear_references,
      desc = 'lsp: clear references',
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
      desc = 'lsp: code action (bulb)',
    })
  end

  if client.supports_method(M.textDocument_codeLens) then
    local group = vim.api.nvim_create_augroup('dm__lsp_code_lens_refresh', { clear = false })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
    vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
      group = group,
      buffer = bufnr,
      callback = function()
        lsp.codelens.refresh { bufnr = bufnr }
      end,
      desc = 'lsp: refresh codelens',
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

  local client_extension = extensions[client.name]
  if client_extension then
    client_extension.on_attach(client, bufnr)
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
  desc = 'lsp: setup language server',
})
