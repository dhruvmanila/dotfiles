local icons = require("core.icons").icons
local kind_icons = require("core.icons").lsp_kind
local map = require("core.utils").map
local cmd = vim.api.nvim_command
local sign_define = vim.fn.sign_define

-- Utiliy functions, commands and keybindings
-- FIXME: this only stops the client
function _G._reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  cmd("edit")
end

function _G._open_lsp_log()
  cmd("botright split")
  cmd("resize 20")
  cmd("edit " .. vim.lsp.get_log_path())
end

cmd("command! -nargs=0 LspRestart call v:lua._reload_lsp()")
cmd("command! -nargs=0 LspLog call v:lua._open_lsp_log()")

map("n", "<Leader>ll", "<Cmd>LspLog<CR>")
map("n", "<Leader>lr", "<Cmd>LspRestart<CR>")
-- map('n', '<Leader>li', '<Cmd>LspInfo<CR>')

-- Adding VSCode like icons to the completion menu.
-- vscode-codicons: https://github.com/microsoft/vscode-codicons
require("vim.lsp.protocol").CompletionItemKind = (function()
  local items = {}
  for i, info in ipairs(kind_icons) do
    local icon, name = unpack(info)
    items[i] = icon .. "  " .. name
  end
  return items
end)()

-- Update the default signs
sign_define("LspDiagnosticsSignError", { text = icons.error })
sign_define("LspDiagnosticsSignWarning", { text = icons.warning })
sign_define("LspDiagnosticsSignInformation", { text = icons.info })
sign_define("LspDiagnosticsSignHint", { text = icons.hint })
sign_define("LightBulbSign", {
  text = icons.lightbulb,
  texthl = "LspDiagnosticsSignHint",
})
