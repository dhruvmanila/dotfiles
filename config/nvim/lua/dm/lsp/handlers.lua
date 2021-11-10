local lsp = vim.lsp
local api = vim.api
local handlers = lsp.handlers

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
      vim.diagnostic.setqflist { title = ctx.method }
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

-- Override the handler to notify regarding the rename stats. This includes the
-- number of renames made in each file.
handlers["textDocument/rename"] = function(_, result, ctx)
  if not result then
    return
  end

  if result.changes then
    local lines = {}
    for uri, change in pairs(result.changes) do
      local fname = vim.uri_to_fname(uri)
      fname = vim.fn.fnamemodify(fname, ":~:.")
      lines[#lines + 1] = ("%2d: %s"):format(#change, fname)
    end
    local heading = (" Renamed -> %s\n\n"):format(ctx.params.newName)
    dm.notify("LSP Rename Stats", heading .. table.concat(lines, "\n"))
  end

  lsp.util.apply_workspace_edit(result)
end
