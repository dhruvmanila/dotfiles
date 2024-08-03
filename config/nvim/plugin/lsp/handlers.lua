local M = vim.lsp.protocol.Methods

-- Modified version of the original handler. This will open the quickfix
-- window only if the response is a list and the count is greater than 1.
local function location_handler(err, result, ctx)
  local title = 'LSP (' .. ctx.method .. ')'
  if err then
    dm.notify(title, tostring(err), vim.log.levels.ERROR)
    return
  end
  if result == nil or vim.tbl_isempty(result) then
    dm.notify(title, 'No results found')
    return
  end

  -- Response: Location | Location[] | LocationLink[] | null
  -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then
    dm.notify(title, 'No client found', vim.log.levels.WARN)
    return
  end

  if vim.islist(result) then
    vim.lsp.util.jump_to_location(result[1], client.offset_encoding)
    if vim.tbl_count(result) > 1 then
      vim.fn.setqflist({}, ' ', {
        title = title,
        items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
      })
      vim.api.nvim_command 'copen | wincmd p | cc 1'
    end
  else
    vim.lsp.util.jump_to_location(result, client.offset_encoding, true)
  end
end

vim.lsp.handlers[M.textDocument_definition] = location_handler
vim.lsp.handlers[M.textDocument_declaration] = location_handler
vim.lsp.handlers[M.textDocument_typeDefinition] = location_handler
vim.lsp.handlers[M.textDocument_implementation] = location_handler
vim.lsp.handlers[M.textDocument_references] = location_handler

do
  -- See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#messageType
  local levels = {
    vim.log.levels.ERROR, -- MessageType.Error
    vim.log.levels.WARN, -- MessageType.Warning
    vim.log.levels.INFO, -- MessageType.Info
    vim.log.levels.INFO, -- MessageType.Log
    vim.log.levels.DEBUG, -- MessageType.Debug
  }

  -- See: https://github.com/neovim/nvim-lspconfig/wiki/User-contributed-tips#use-nvim-notify-to-display-lsp-messages
  vim.lsp.handlers[M.window_showMessage] = function(err, result, ctx)
    local title = 'LSP (' .. ctx.method .. ')'
    if err ~= nil then
      dm.notify(title, tostring(err), vim.log.levels.ERROR)
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client == nil then
      dm.notify(title, 'No client found', vim.log.levels.WARN)
      return
    end
    dm.notify(('Server message (%s)'):format(client.name), result.message, levels[result.type])
  end
end

do
  local MessageType = vim.lsp.protocol.MessageType

  -- Override the original handler to allow us to divert the log messages for each server in a
  -- separate log file using the custom logging module.
  vim.lsp.handlers[M.window_logMessage] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client == nil then
      dm.notify('LSP log message', 'No client found', vim.log.levels.WARN)
      return
    end
    local logger = dm.log.get_logger('lsp.' .. client.name)
    -- Keep the logger level in sync with `vim.lsp`. This is important for `LspSetLogLevel` command.
    logger.set_level(vim.lsp.log.get_level())
    if result.type == MessageType.Error then
      logger.error(result.message)
    elseif result.type == MessageType.Warning then
      logger.warn(result.message)
    elseif result.type == MessageType.Info or result.type == MessageType.Log then
      logger.info(result.message)
    else
      logger.debug(result.message)
    end
  end
end

-- Neovim does not currently report the related locations for diagnostics.
--
-- Refer:
-- 1. https://github.com/neovim/neovim/issues/19649#issuecomment-1327287313
-- 2. https://github.com/neovim/neovim/issues/22744#issuecomment-1479366923
--
-- TODO: Remove this once a PR for this is merged
do
  local original_handler = vim.lsp.handlers[M.textDocument_publishDiagnostics]

  -- See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#diagnosticRelatedInformation
  local function show_related_information(diagnostic)
    local related_info = diagnostic.relatedInformation
    if not related_info or #related_info == 0 then
      return diagnostic
    end
    for _, info in ipairs(related_info) do
      diagnostic.message = ('%s\n%s(%d:%d): %s'):format(
        diagnostic.message,
        vim.fn.fnamemodify(vim.uri_to_fname(info.location.uri), ':p:.'),
        info.location.range.start.line + 1,
        info.location.range.start.character + 1,
        info.message
      )
    end
    return diagnostic
  end

  vim.lsp.handlers[M.textDocument_publishDiagnostics] = function(err, result, ctx, config)
    result.diagnostics = vim.tbl_map(show_related_information, result.diagnostics)
    original_handler(err, result, ctx, config)
  end
end

vim.lsp.handlers[M.workspace_diagnostic_refresh] = function(_, _, ctx, _)
  local buffers = vim
    .iter(vim.api.nvim_list_bufs())
    :filter(function(bufnr)
      if vim.fn.buflisted(bufnr) ~= 1 then
        return false
      end
      if not vim.api.nvim_buf_is_loaded(bufnr) then
        return false
      end
      return true
    end)
    :totable()

  for _, bufnr in ipairs(buffers) do
    local clients = vim.lsp.get_clients {
      bufnr = bufnr,
      method = M.textDocument_diagnostic,
      id = ctx.client_id,
    }
    if #clients > 0 then
      for _, client in ipairs(clients) do
        client.request(M.textDocument_diagnostic, {
          textDocument = vim.lsp.util.make_text_document_params(bufnr),
        }, nil, bufnr)
      end
    end
  end

  return vim.NIL
end
