---@diagnostic disable: duplicate-set-field

-- Modified version of the original handler. This will open the quickfix
-- window only if the response is a list and the count is greater than 1.
local function location_handler(err, result, ctx)
  local title = 'LSP (' .. ctx.method .. ')'
  if err then
    dm.notify(title, tostring(err), 4)
    return
  end
  if result == nil or vim.tbl_isempty(result) then
    dm.notify(title, 'No results found')
    return
  end

  -- Response: Location | Location[] | LocationLink[] | null
  -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1], client.offset_encoding)
    if vim.tbl_count(result) > 1 then
      vim.fn.setqflist({}, ' ', {
        title = title,
        items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
      })
      vim.api.nvim_command 'copen | wincmd p'
    end
  else
    vim.lsp.util.jump_to_location(result, client.offset_encoding, true)
  end
end

vim.lsp.handlers['textDocument/definition'] = location_handler
vim.lsp.handlers['textDocument/declaration'] = location_handler
vim.lsp.handlers['textDocument/typeDefinition'] = location_handler
vim.lsp.handlers['textDocument/implementation'] = location_handler

do
  local levels = {
    vim.log.levels.ERROR,
    vim.log.levels.WARN,
    vim.log.levels.INFO,
    vim.log.levels.DEBUG,
  }

  -- See: https://github.com/neovim/nvim-lspconfig/wiki/User-contributed-tips#use-nvim-notify-to-display-lsp-messages
  vim.lsp.handlers['window/showMessage'] = function(err, result, ctx)
    if err then
      dm.notify('LSP', tostring(err), vim.log.levels.ERROR)
      return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or ('id=%d'):format(ctx.client_id)

    dm.notify(('LSP Message (%s)'):format(client_name), result.message, levels[result.type])
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
  local original_handler = vim.lsp.handlers['textDocument/publishDiagnostics']

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

  vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
    result.diagnostics = vim.tbl_map(show_related_information, result.diagnostics)
    original_handler(err, result, ctx, config)
  end
end
