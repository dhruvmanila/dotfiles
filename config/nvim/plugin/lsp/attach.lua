if vim.g.vscode then
  return
end

local lsp = vim.lsp
local M = lsp.protocol.Methods

local extensions = require 'dm.lsp.extensions'

-- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
lsp.log.set_level(vim.env.NVIM_LSP_LOG_LEVEL or dm.log.get_level())
require('vim.lsp.log').set_format_func(dm.log.lsp_log_format_func)

-- Set the default options for all LSP floating windows.
--   - Default border according to `dm.config.border_style`
--   - Limit width and height of the window
do
  local default_open_floating_preview = lsp.util.open_floating_preview

  ---@diagnostic disable-next-line: duplicate-set-field
  lsp.util.open_floating_preview = function(contents, syntax, opts)
    opts = vim.tbl_deep_extend('force', opts, {
      border = dm.border,
      max_width = math.min(math.floor(vim.o.columns * 0.7), 120),
      max_height = math.min(math.floor(vim.o.lines * 0.3), 40),
    })
    local bufnr, winnr = default_open_floating_preview(contents, syntax, opts)
    -- As per `:h 'showbreak'`, the value should be a literal "NONE".
    vim.wo[winnr].showbreak = 'NONE'
    return bufnr, winnr
  end
end

-- Create a function that will perform the file renaming operation using the given LSP `client`.
---@param client vim.lsp.Client
local function rename_file(client)
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
    local response = client:request_sync(M.workspace_willRenameFiles, params, 1000)
    if not response then
      dm.log.warn('No response from %s client for %s', client.name, M.workspace_willRenameFiles)
      return
    end
    if response.err then
      dm.log.error('Failed to rename %s to %s: %s', old_fname, new_fname, response.err)
    else
      lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
      lsp.util.rename(old_fname, new_fname)
    end
  end)
end

-- Custom handler for requests that returns a list of locations (e.g. definition, references).
--
-- This handler will go to the first location unconditionally and open the quickfix list if there
-- are more than one locations.
---@param client vim.lsp.Client
local function create_on_list(client)
  ---@param opts vim.lsp.LocationOpts.OnList
  return function(opts)
    -- The `user_data` field contains the original location data from the server.
    lsp.util.show_document(opts.items[1].user_data, client.offset_encoding, {
      focus = true,
      reuse_win = false,
    })
    if vim.tbl_count(opts.items) > 1 then
      -- As per the docs, `opts` can be used directly in `setqflist` or `setloclist`.
      ---@diagnostic disable-next-line: param-type-mismatch
      vim.fn.setqflist({}, ' ', opts)
      vim.api.nvim_command 'copen | wincmd p'
    end
    dm.center_cursor()
  end
end

-- Setup the buffer local mappings for the LSP client.
---@param client vim.lsp.Client
---@param bufnr number
local function setup_mappings(client, bufnr)
  if client:supports_method(M.textDocument_definition) then
    vim.keymap.set('n', 'gd', function()
      lsp.buf.definition { on_list = create_on_list(client) }
    end, {
      buffer = bufnr,
      desc = 'lsp: [g]oto [d]efinition',
    })
  end

  if client:supports_method(M.textDocument_declaration) then
    vim.keymap.set('n', 'gD', function()
      lsp.buf.declaration { on_list = create_on_list(client) }
    end, {
      buffer = bufnr,
      desc = 'lsp: [g]oto [D]eclaration',
    })
  end

  if client:supports_method(M.textDocument_typeDefinition) then
    vim.keymap.set('n', 'gy', function()
      lsp.buf.type_definition { on_list = create_on_list(client) }
    end, {
      buffer = bufnr,
      desc = 'lsp: [g]oto t[y]pe definition',
    })
  end

  if client:supports_method(M.textDocument_implementation) then
    vim.keymap.set('n', 'gi', function()
      lsp.buf.implementation { on_list = create_on_list(client) }
    end, {
      buffer = bufnr,
      desc = 'lsp: [g]oto [i]mplementation',
    })
  end

  if client:supports_method(M.textDocument_references) then
    vim.keymap.set('n', 'gr', function()
      lsp.buf.references({ includeDeclaration = false }, { on_list = create_on_list(client) })
    end, {
      buffer = bufnr,
      desc = 'lsp: [g]oto [r]eferences',
    })
  end

  if client:supports_method(M.textDocument_rename) then
    -- Rename handler for the beancount language server.
    --
    -- For beancount, the <cword> should contain the full symbol name (e.g., `Assets:Bank:Account`)
    -- instead of just the part where the cursor is at (e.g., `Account`). To achieve this, we
    -- temporarily add `:` to the `iskeyword` option to make sure the entire symbol name is captured
    -- in `<cword>`.
    --
    -- This shouldn't be required if the server supports `textDocument/prepareRename` and returns
    -- the correct placeholder, but it doesn't at the time of writing.
    local function beancount_rename()
      vim.opt_local.iskeyword:append ':'
      local cword = vim.fn.expand '<cword>'
      vim.opt_local.iskeyword:remove ':'
      vim.ui.input({ prompt = 'New Name: ', default = cword }, function(input)
        if input and input ~= '' then
          lsp.buf.rename(input)
        end
      end)
    end

    vim.keymap.set('n', '<leader>rn', function()
      if client.name == 'beancount' then
        beancount_rename()
      else
        lsp.buf.rename()
      end
    end, {
      buffer = bufnr,
      desc = 'lsp: [r]e[n]ame all symbol references',
    })
  end

  if client:supports_method(M.textDocument_codeAction) then
    vim.keymap.set({ 'n', 'x' }, '<leader>ca', lsp.buf.code_action, {
      buffer = bufnr,
      desc = 'lsp: select [c]ode [a]ction',
    })
  end

  if client:supports_method(M.textDocument_codeLens) then
    vim.keymap.set('n', '<leader>cl', lsp.codelens.run, {
      buffer = bufnr,
      desc = 'lsp: run [c]ode [l]ens',
    })
  end

  if client:supports_method(M.textDocument_inlayHint) then
    vim.keymap.set('n', '<leader>ih', function()
      local is_enabled = lsp.inlay_hint.is_enabled { bufnr = bufnr }
      lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
    end, { desc = 'lsp: toggle [i]nlay [h]int for buffer' })

    vim.keymap.set('n', '<leader>iH', function()
      local is_enabled = lsp.inlay_hint.is_enabled()
      lsp.inlay_hint.enable(not is_enabled)
    end, { desc = 'lsp: toggle [i]nlay [H]int globally' })
  end

  if client:supports_method(M.workspace_willRenameFiles) then
    vim.keymap.set('n', '<leader>rf', function()
      rename_file(client)
    end, {
      buffer = bufnr,
      desc = 'lsp: [r]ename [f]ile',
    })
  end
end

-- Setup the buffer local autocmds for the LSP client.
---@param client vim.lsp.Client
---@param bufnr number
local function setup_autocmds(client, bufnr)
  if client:supports_method(M.textDocument_documentHighlight) then
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

  if client:supports_method(M.textDocument_codeLens) then
    local group = vim.api.nvim_create_augroup('dm__lsp_code_lens_refresh', { clear = false })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
    vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
      group = group,
      buffer = bufnr,
      callback = function()
        lsp.codelens.enable(true, { bufnr = bufnr })
      end,
      desc = 'lsp: refresh codelens',
    })
  end

  if
    vim.tbl_contains(dm.config.inlay_hints.enable, client.name)
    and client:supports_method(M.textDocument_inlayHint)
  then
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
