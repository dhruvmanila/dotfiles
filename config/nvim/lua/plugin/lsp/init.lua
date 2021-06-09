local cmd = vim.api.nvim_command
local sign_define = vim.fn.sign_define
local nvim_buf_set_keymap = api.nvim_buf_set_keymap

local icons = require("core.icons")
local map = require("core.utils").map
local lspconfig = require("lspconfig")
local lspstatus = require("lsp-status")

require("core.formatter")
require("plugin.lsp.handlers")

local plugins = require("plugin.lsp.plugins")
local servers = require("plugin.lsp.servers")

-- For debugging purposes:
-- vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)

-- Utiliy functions, commands and keybindings
local function open_lsp_log()
  cmd("botright split")
  cmd("resize 20")
  cmd("edit " .. vim.lsp.get_log_path())
  vim.api.nvim_win_set_option(0, "wrap", false)
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

-- Set the default options for all LSP floating windows.
--   - Default border according to `vim.g.border_style`
--   - 'q' to quit with `nowait = true`
do
  local default = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    opts = vim.tbl_deep_extend("force", opts, {
      border = icons.border[vim.g.border_style],
    })
    local bufnr, winnr = default(contents, syntax, opts)
    local o = { noremap = true, nowait = true, silent = true }
    nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>bdelete<CR>", o)
    return bufnr, winnr
  end
end

-- The main `on_attach` function to be called by each of the language server
-- to setup the required keybindings and functionalities provided by other
-- plugins.
--
-- This function needs to be passed to every language server. If a language
-- server requires either more config or less, it should also be done in this
-- function using the `filetype` conditions.
local function custom_on_attach(client, bufnr)
  local lsp_autocmds = {}
  local capabilities = client.resolved_capabilities

  -- For plugins with an `on_attach` callback, call them here.
  plugins.on_attach(client)

  -- Used to setup per filetype
  -- local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

  -- Keybindings:
  -- For all types of diagnostics: [d | ]d
  -- For warning and error diagnostics: [e | ]e
  local mappings = {
    ["n [d"] = "vim.lsp.diagnostic.goto_prev({enable_popup = false})",
    ["n ]d"] = "vim.lsp.diagnostic.goto_next({enable_popup = false})",
    ["n ]e"] = "vim.lsp.diagnostic.goto_prev({severity_limit = 'Warning', enable_popup = false})",
    ["n [e"] = "vim.lsp.diagnostic.goto_next({severity_limit = 'Warning', enable_popup = false})",
    ["n <leader>ld"] = "require('plugin.lsp.diagnostics').show_line_diagnostics()",
  }

  if capabilities.hover then
    mappings["n K"] = "vim.lsp.buf.hover()"
  end

  if capabilities.goto_definition then
    mappings["n gd"] = "vim.lsp.buf.definition()"
    mappings["n <leader>pd"] = "require('plugin.lsp.preview').definition()"
  end

  if capabilities.declaration then
    mappings["n gD"] = "vim.lsp.buf.declaration()"
    mappings["n <leader>pD"] = "require('plugin.lsp.preview').declaration()"
  end

  if capabilities.type_definition then
    mappings["n gy"] = "vim.lsp.buf.type_definition()"
    mappings["n <leader>py"] = "require('plugin.lsp.preview').type_definition()"
  end

  if capabilities.implementation then
    mappings["n gi"] = "vim.lsp.buf.implementation()"
    mappings["n <leader>pi"] = "require('plugin.lsp.preview').implementation()"
  end

  if capabilities.find_references then
    mappings["n gr"] = "vim.lsp.buf.references()"
  end

  if capabilities.rename then
    mappings["n <leader>rn"] = "require('plugin.lsp.rename').rename()"
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
    table.insert(lsp_autocmds, {
      events = { "CursorHold" },
      targets = { "<buffer>" },
      command = require("plugin.lsp.diagnostics").show_line_diagnostics,
    })
  end

  if capabilities.signature_help then
    if not plugin_loaded("lsp_signature.nvim") then
      require("packer").loader("lsp_signature.nvim")
    end

    require("lsp_signature").on_attach({
      bind = true,
      doc_lines = 0,
      hint_enable = false,
      use_lspsaga = false,
      handler_opts = {
        border = icons.border[vim.g.border_style],
      },
      hi_parameter = "YellowItalic",
    })

    mappings["n <C-s>"] = "vim.lsp.buf.signature_help()"
  end

  if capabilities.code_action then
    if not plugin_loaded("nvim-lightbulb") then
      require("packer").loader("nvim-lightbulb")
    end

    table.insert(lsp_autocmds, {
      events = { "CursorHold", "CursorHoldI" },
      targets = { "<buffer>" },
      command = require("nvim-lightbulb").update_lightbulb,
    })

    mappings["n <leader>ca"] = "vim.lsp.buf.code_action()"
    mappings["x <leader>ca"] = "vim.lsp.buf.range_code_action()"
  end

  -- Set the LSP autocmds
  if not vim.tbl_isempty(lsp_autocmds) then
    dm.augroup("custom_lsp_autocmds", lsp_autocmds)
  end

  -- Set the LSP mappings
  do
    local mode
    local opts = { noremap = true, silent = true }

    for key, command in pairs(mappings) do
      mode, key = key:match("^(.)[ ]*(.+)$")
      command = "<Cmd>lua " .. command .. "<CR>"
      nvim_buf_set_keymap(bufnr, mode, key, command, opts)
    end
  end

  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
end

---Setting up the servers with the provided configuration and additional
---capabilities.
for server, config in pairs(servers) do
  config = type(config) == "function" and config() or config
  config.on_attach = custom_on_attach
  config.capabilities = vim.tbl_deep_extend(
    "keep",
    config.capabilities or vim.lsp.protocol.make_client_capabilities(),
    lspstatus.capabilities
  )
  -- TODO: Update server after adding a snippet plugin
  -- config.capabilities.textDocument.completion.completionItem.snippetSupport =
  --   true
  config.capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }
  lspconfig[server].setup(config)
end
