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
    vim.lsp.util.jump_to_location(result, client.offset_encoding)
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
    local client_name = client and client.name
      or ('id=%d'):format(ctx.client_id)

    dm.notify(
      ('LSP Message (%s)'):format(client_name),
      result.message,
      levels[result.type]
    )
  end
end
