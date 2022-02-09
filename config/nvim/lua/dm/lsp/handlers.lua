-- Modified version of the original handler. This will open the quickfix
-- window only if the response is a list and the count is greater than 1.
local function location_handler(err, result, ctx)
  local title = "LSP (" .. ctx.method .. ")"
  if err then
    dm.notify(title, tostring(err))
    return
  end
  if result == nil or vim.tbl_isempty(result) then
    dm.notify(title, "No results found")
    return
  end

  -- Response: Location | Location[] | LocationLink[] | null
  -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1], client.offset_encoding)
    if vim.tbl_count(result) > 1 then
      vim.fn.setqflist({}, " ", {
        title = title,
        items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
      })
      vim.api.nvim_command "copen | wincmd p"
    end
  else
    vim.lsp.util.jump_to_location(result, client.offset_encoding)
  end
end

vim.lsp.handlers["textDocument/definition"] = location_handler
vim.lsp.handlers["textDocument/declaration"] = location_handler
vim.lsp.handlers["textDocument/typeDefinition"] = location_handler
vim.lsp.handlers["textDocument/implementation"] = location_handler
