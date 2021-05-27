local lsp = vim.lsp
local api = vim.api
local handlers = lsp.handlers
local code_action = require("plugin.lsp.code_action")
local border = require("core.icons").border

-- Can use `lsp.diagnostics.show_line_diagnostic()` instead of `virtual_text`
handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = false,
    underline = true,
    signs = true,
    update_in_insert = false,
  }
)

-- Press 'K' for hover and then 'K' again to enter the hover window.
-- Press 'q' to quit.
handlers["textDocument/hover"] = function(...)
  local bufnr, _ = vim.lsp.with(vim.lsp.handlers.hover, {
    border = border.edge,
  })(...)

  local opts = { noremap = true, nowait = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>quit<CR>", opts)
end

handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = border.edge,
  }
)

handlers["textDocument/codeAction"] = code_action.handler

-- Modified version of the original handler. This will open the quickfix
-- window only if the response is a list and the count is greater than 1.
local function location_handler(_, _, response)
  if not response or vim.tbl_isempty(response) then
    print("[LSP] No definition found")
    return
  end

  -- Response: Location | Location[] | LocationLink[] | null
  -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition
  if vim.tbl_islist(response) then
    if vim.tbl_count(response) > 1 then
      lsp.util.set_qflist(lsp.util.locations_to_items(response))
      api.nvim_command("copen")
      api.nvim_command("wincmd p")
    end
    lsp.util.jump_to_location(response[1])
  else
    lsp.util.jump_to_location(response)
  end
end

handlers["textDocument/definition"] = location_handler
handlers["textDocument/declaration"] = location_handler
handlers["textDocument/typeDefinition"] = location_handler
handlers["textDocument/implementation"] = location_handler
