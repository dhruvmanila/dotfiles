local M = {}

local lsp = vim.lsp
local icons = require("core.icons")

local function preview_location_callback(_, _, response)
  if not response or vim.tbl_isempty(response) then
    return
  end
  response = vim.tbl_islist(response) and response[1] or response
  lsp.util.preview_location(response, { border = icons.border.edge })
end

local function make_lsp_preview_action(method)
  return function()
    local params = lsp.util.make_position_params()
    lsp.buf_request(0, method, params, preview_location_callback)
  end
end

M.definition = make_lsp_preview_action("textDocument/definition")
M.declaration = make_lsp_preview_action("textDocument/declaration")
M.implementation = make_lsp_preview_action("textDocument/implementation")
M.type_definition = make_lsp_preview_action("textDocument/typeDefinition")

return M
