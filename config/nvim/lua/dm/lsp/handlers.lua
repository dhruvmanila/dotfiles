local lsp = vim.lsp
local api = vim.api
local handlers = lsp.handlers

-- Can use `lsp.diagnostics.show_line_diagnostic()` instead of `virtual_text`
handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = false,
    underline = false,
    signs = true,
    update_in_insert = false,
  }
)

-- Modified version of the original handler. This will open the quickfix
-- window only if the response is a list and the count is greater than 1.
local function location_handler(_, result, ctx)
  if not result or vim.tbl_isempty(result) then
    dm.notify("LSP (" .. ctx.method .. ")", "No results found")
    return
  end

  -- Response: Location | Location[] | LocationLink[] | null
  -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
  if vim.tbl_islist(result) then
    if vim.tbl_count(result) > 1 then
      lsp.util.set_qflist(lsp.util.locations_to_items(result))
      api.nvim_command "copen"
      api.nvim_command "wincmd p"
    end
    lsp.util.jump_to_location(result[1])
  else
    lsp.util.jump_to_location(result)
  end
end

handlers["textDocument/definition"] = location_handler
handlers["textDocument/declaration"] = location_handler
handlers["textDocument/typeDefinition"] = location_handler
handlers["textDocument/implementation"] = location_handler
