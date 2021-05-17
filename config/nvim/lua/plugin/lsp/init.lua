local cmd = vim.api.nvim_command
local sign_define = vim.fn.sign_define

local icons = require("core.icons")
local map = require("core.utils").map
local lspconfig = require("lspconfig")
local lspstatus = require("lsp-status")

require("core.format")
require("pylance")
require("plugin.lsp.handlers")

local plugins = require("plugin.lsp.plugins")
local servers = require("plugin.lsp.servers")

-- For debugging purposes:
-- vim.lsp.set_log_level("debug")

-- Utiliy functions, commands and keybindings
local function open_lsp_log()
  cmd("botright split")
  cmd("resize 20")
  cmd("edit " .. vim.lsp.get_log_path())
end

dm.command({ "LspLog", open_lsp_log })

map("n", "<Leader>ll", "<Cmd>LspLog<CR>")
map("n", "<Leader>lr", "<Cmd>LspRestart<CR>")

-- Adding VSCode like icons to the completion menu.
-- vscode-codicons: https://github.com/microsoft/vscode-codicons
require("vim.lsp.protocol").CompletionItemKind = (function()
  local items = {}
  for i, info in ipairs(icons.lsp_kind) do
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

local opts = { noremap = true }

local function buf_map(key, func, mode)
  mode = mode or "n"
  local command = "<Cmd>lua " .. func .. "<CR>"
  vim.api.nvim_buf_set_keymap(0, mode, key, command, opts)
end

-- The main `on_attach` function to be called by each of the language server
-- to setup the required keybindings and functionalities provided by other
-- plugins.
--
-- This function needs to be passed to every language server. If a language
-- server requires either more config or less, it should also be done in this
-- function using the `filetype` conditions.
local function custom_on_attach(client)
  local lsp_autocmds = {}
  local capabilities = client.resolved_capabilities

  -- For plugins with an `on_attach` callback, call them here.
  plugins.on_attach(client)

  -- Used to setup per filetype
  -- local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

  -- Keybindings:
  -- For all types of diagnostics: [d | ]d
  -- For warning and error diagnostics: [e | ]e
  -- { enable_popup = false }
  -- local edge_border = "require('core.icons').border.edge"
  -- local popup_opts = string.format(
  --   "{show_header = false, border = %s}",
  --   edge_border
  -- )
  buf_map("[d", "vim.lsp.diagnostic.goto_prev({enable_popup = false})")
  buf_map("]d", "vim.lsp.diagnostic.goto_next({enable_popup = false})")
  buf_map(
    "[e",
    "vim.lsp.diagnostic.goto_prev({severity_limit = 'Warning', enable_popup = false})"
  )
  buf_map(
    "]e",
    "vim.lsp.diagnostic.goto_next({severity_limit = 'Warning', enable_popup = false})"
  )
  buf_map("gl", "require('plugin.lsp.diagnostics').show_line_diagnostics()")
  buf_map("K", "vim.lsp.buf.hover()")
  buf_map("gd", "vim.lsp.buf.definition()")
  buf_map("gD", "vim.lsp.buf.declaration()")
  buf_map("gy", "vim.lsp.buf.type_definition()")
  buf_map("gi", "vim.lsp.buf.implementation()")
  buf_map("gr", "vim.lsp.buf.references()")

  if capabilities.signature_help then
    buf_map("<C-s>", "vim.lsp.buf.signature_help()")
  end

  if capabilities.rename then
    buf_map("<Leader>rn", "require('plugin.lsp.rename').rename()")
  end

  -- Setup auto-formatting on save if the language server supports it.
  if capabilities.document_formatting then
    buf_map("<Leader>lf", "vim.lsp.buf.formatting()")
    -- TODO: auto format setup as per the configuration option b.auto_format_<ft> ?
    -- table.insert(lsp_autocmds, {
    --   events = { "BufWritePre" },
    --   targets = { "<buffer>" },
    --   command = function()
    --     vim.lsp.buf.formatting_sync(nil, 1000)
    --   end,
    -- })
  end

  -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
  if capabilities.document_highlight then
    table.insert(lsp_autocmds, {
      events = { "CursorHold" },
      targets = { "<buffer>" },
      command = vim.lsp.buf.document_highlight,
    })
    table.insert(lsp_autocmds, {
      events = { "CursorMoved" },
      targets = { "<buffer>" },
      command = vim.lsp.buf.clear_references,
    })
    -- table.insert(lsp_autocmds, {
    --   events = { "CursorHold" },
    --   targets = { "<buffer>" },
    --   command = function()
    --     vim.lsp.diagnostic.show_line_diagnostics({ show_header = false })
    --   end,
    -- })
  end

  if capabilities.code_action then
    cmd("packadd nvim-lightbulb")

    table.insert(lsp_autocmds, {
      events = { "CursorHold", "CursorHoldI" },
      targets = { "<buffer>" },
      command = require("nvim-lightbulb").update_lightbulb,
    })
    buf_map("ga", "vim.lsp.buf.code_action()")
  end

  if not vim.tbl_isempty(lsp_autocmds) then
    dm.augroup("custom_lsp_autocmds", lsp_autocmds)
  end

  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
end

-- Override the default capabilities and pass it to the language server on
-- initialization. E.g., adding snippets supports.
-- local client_capabilities = lsp.protocol.make_client_capabilities()

-- TODO: Update server **only** after adding a snippet plugin
-- local snippet_capabilities = {
--   textDocument = {
--     completion = {
--       completionItem = {
--         snippetSupport = true
--       }
--     }
--   }
-- }

---Setting up the servers with the provided configuration and additional
---capabilities.
for server, config in pairs(servers) do
  config = type(config) == "function" and config() or config
  config.on_attach = custom_on_attach
  config.capabilities = vim.tbl_deep_extend(
    "keep",
    config.capabilities or {},
    lspstatus.capabilities
  )
  lspconfig[server].setup(config)
end
