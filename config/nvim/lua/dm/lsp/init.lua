local icons = dm.icons
local nnoremap = dm.nnoremap
local xnoremap = dm.xnoremap

local lspconfig = require "lspconfig"
local plugins = require "dm.lsp.plugins"
local servers = require "dm.lsp.servers"
local preview = require "dm.lsp.preview"

require "dm.formatter"
require "dm.lsp.handlers"

-- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
vim.lsp.set_log_level "info"

nnoremap("<Leader>ll", "<Cmd>LspLog<CR>")
nnoremap("<Leader>lr", "<Cmd>LspRestart<CR>")

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
vim.fn.sign_define {
  { name = "LspDiagnosticsSignError", text = icons.error },
  { name = "LspDiagnosticsSignWarning", text = icons.warning },
  { name = "LspDiagnosticsSignInformation", text = icons.info },
  { name = "LspDiagnosticsSignHint", text = icons.hint },
}

-- Set the default options for all LSP floating windows.
--   - Default border according to `vim.g.border_style`
--   - 'q' to quit with `nowait = true`
--   - Max width and height of the window as per the editor width and height
do
  local default = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
    opts = vim.tbl_deep_extend("force", opts, {
      border = dm.border[vim.g.border_style],
      max_width = max_width,
      max_height = math.max(math.floor(vim.o.lines * 0.3), 30),
      wrap_at = max_width,
    })
    local bufnr, winnr = default(contents, syntax, opts)
    nnoremap("q", "<Cmd>bdelete<CR>", { buffer = bufnr, nowait = true })
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
  nnoremap("[d", function()
    vim.lsp.diagnostic.goto_prev { enable_popup = false }
  end, {
    buffer = bufnr,
  })
  nnoremap("]d", function()
    vim.lsp.diagnostic.goto_next { enable_popup = false }
  end, {
    buffer = bufnr,
  })

  -- For warning and error diagnostics: [e | ]e
  nnoremap("[e", function()
    vim.lsp.diagnostic.goto_prev {
      severity_limit = "Warning",
      enable_popup = false,
    }
  end, {
    buffer = bufnr,
  })
  nnoremap("]e", function()
    vim.lsp.diagnostic.goto_next {
      severity_limit = "Warning",
      enable_popup = false,
    }
  end, {
    buffer = bufnr,
  })

  -- Custom popup to show line diagnostics with colors and source information.
  nnoremap(
    "<leader>ld",
    require("dm.lsp.diagnostics").show_line_diagnostics,
    { buffer = bufnr }
  )

  if capabilities.hover then
    nnoremap("K", vim.lsp.buf.hover, { buffer = bufnr })
  end

  if capabilities.goto_definition then
    nnoremap("gd", vim.lsp.buf.definition, { buffer = bufnr })
    nnoremap("<leader>pd", preview.definition, { buffer = bufnr })
  end

  if capabilities.declaration then
    nnoremap("gD", vim.lsp.buf.declaration, { buffer = bufnr })
    nnoremap("<leader>pD", preview.declaration, { buffer = bufnr })
  end

  if capabilities.type_definition then
    nnoremap("gy", vim.lsp.buf.type_definition, { buffer = bufnr })
    nnoremap("<leader>py", preview.type_definition, { buffer = bufnr })
  end

  if capabilities.implementation then
    nnoremap("gi", vim.lsp.buf.implementation, { buffer = bufnr })
    nnoremap("<leader>pi", preview.implementation, { buffer = bufnr })
  end

  if capabilities.find_references then
    nnoremap("gr", vim.lsp.buf.references, { buffer = bufnr })
  end

  if capabilities.rename then
    nnoremap("<leader>rn", require("dm.lsp.rename").rename, { buffer = bufnr })
  end

  -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
  if capabilities.document_highlight then
    table.insert(lsp_autocmds, {
      events = "CursorHold",
      targets = "<buffer>",
      command = vim.lsp.buf.document_highlight,
    })
    table.insert(lsp_autocmds, {
      events = "CursorMoved",
      targets = "<buffer>",
      command = vim.lsp.buf.clear_references,
    })
    table.insert(lsp_autocmds, {
      events = "CursorHold",
      targets = "<buffer>",
      command = require("dm.lsp.diagnostics").show_line_diagnostics,
    })
  end

  if capabilities.signature_help then
    nnoremap("<C-s>", vim.lsp.buf.signature_help, { buffer = bufnr })
  end

  if capabilities.code_action then
    local builtin = require "telescope.builtin"

    table.insert(lsp_autocmds, {
      events = { "CursorHold", "CursorHoldI" },
      targets = "<buffer>",
      command = require("dm.lsp.code_action").code_action_listener,
    })

    nnoremap("<leader>ca", builtin.lsp_code_actions, { buffer = bufnr })
    xnoremap("<leader>ca", builtin.lsp_range_code_actions, { buffer = bufnr })
  end

  -- Set the LSP autocmds
  if not vim.tbl_isempty(lsp_autocmds) then
    dm.augroup("custom_lsp_autocmds", lsp_autocmds)
  end

  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
end

do
  -- Define default client capabilities.
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  -- Setting up the servers with the provided configuration and additional
  -- capabilities.
  for server, config in pairs(servers) do
    config = type(config) == "function" and config() or config
    config.on_attach = custom_on_attach
    config.flags = config.flags or {}
    config.flags.debounce_text_changes = 150
    config.capabilities = vim.tbl_deep_extend(
      "keep",
      config.capabilities or {},
      capabilities
    )
    lspconfig[server].setup(config)
  end
end
