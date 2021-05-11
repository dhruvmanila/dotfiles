local lsp = vim.lsp
local code_action = require("plugin.lsp.handlers.code_action")
local border = require("core.icons").border

-- Can use `lsp.diagnostics.show_line_diagnostic()` instead of `virtual_text`
lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = true,
    underline = true,
    signs = true,
    update_in_insert = false,
  }
)

-- Press 'K' for hover and then 'K' again to enter the hover window.
-- Press 'q' to quit.
lsp.handlers["textDocument/hover"] = function(...)
  local bufnr, _ = vim.lsp.with(vim.lsp.handlers.hover, {
    border = border.edge,
  })(...)

  local opts = { noremap = true, nowait = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>quit<CR>", opts)
end

lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = border.edge,
  }
)

lsp.handlers["textDocument/codeAction"] = code_action.code_action
