local lsp = vim.lsp
local nnoremap = dm.nnoremap
local xnoremap = dm.xnoremap

local lspconfig = require "lspconfig"
local servers = require "dm.lsp.servers"
local preview = require "dm.lsp.preview"

require "dm.formatter"
require "dm.lsp.handlers"
require "dm.lsp.progress"

-- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
lsp.set_log_level(vim.env.DEBUG and "debug" or "warn")
require("vim.lsp.log").set_format_func(vim.inspect)

-- Set the default options for all LSP floating windows.
--   - Default border according to `vim.g.border_style`
--   - 'q' to quit with `nowait = true`
do
  local default = lsp.util.open_floating_preview
  lsp.util.open_floating_preview = function(contents, syntax, opts)
    opts = vim.tbl_deep_extend("force", opts, {
      border = dm.border[vim.g.border_style],
    })
    local bufnr, winnr = default(contents, syntax, opts)
    nnoremap("q", "<Cmd>bdelete<CR>", { buffer = bufnr, nowait = true })
    -- As per `:h 'showbreak'`, the value should be a literal "NONE".
    vim.wo[winnr].showbreak = "NONE"
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
---@param client table
---@param bufnr number
local function custom_on_attach(client, bufnr)
  local lsp_autocmds = {}
  local capabilities = client.resolved_capabilities
  local opts = { buffer = bufnr }

  if capabilities.hover then
    nnoremap("K", lsp.buf.hover, opts)
  end

  if capabilities.goto_definition then
    nnoremap("gd", lsp.buf.definition, opts)
    nnoremap("<leader>pd", preview.definition, opts)
  end

  if capabilities.declaration then
    nnoremap("gD", lsp.buf.declaration, opts)
    nnoremap("<leader>pD", preview.declaration, opts)
  end

  if capabilities.type_definition then
    nnoremap("gy", lsp.buf.type_definition, opts)
    nnoremap("<leader>py", preview.type_definition, opts)
  end

  if capabilities.implementation then
    nnoremap("gi", lsp.buf.implementation, opts)
    nnoremap("<leader>pi", preview.implementation, opts)
  end

  if capabilities.find_references then
    nnoremap("gr", lsp.buf.references, opts)
  end

  if capabilities.rename then
    nnoremap("<leader>rn", require("dm.lsp.rename").rename, opts)
  end

  if capabilities.signature_help then
    nnoremap("<C-s>", lsp.buf.signature_help, opts)
  end

  -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
  if capabilities.document_highlight then
    table.insert(lsp_autocmds, {
      events = "CursorHold",
      targets = "<buffer>",
      command = lsp.buf.document_highlight,
    })
    table.insert(lsp_autocmds, {
      events = "CursorMoved",
      targets = "<buffer>",
      command = lsp.buf.clear_references,
    })
  end

  if capabilities.code_action then
    local builtin = require "telescope.builtin"

    table.insert(lsp_autocmds, {
      events = { "CursorHold", "CursorHoldI" },
      targets = "<buffer>",
      command = require("dm.lsp.code_action").code_action_listener,
    })

    nnoremap("<leader>ca", builtin.lsp_code_actions, opts)
    xnoremap("<leader>ca", builtin.lsp_range_code_actions, opts)
  end

  -- Set the LSP autocmds
  if not vim.tbl_isempty(lsp_autocmds) then
    dm.augroup("custom_lsp_autocmds", lsp_autocmds)
  end

  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
end

do
  -- Define default client capabilities.
  ---@see https://github.com/hrsh7th/cmp-nvim-lsp#setup
  ---@see https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#completionClientCapabilities
  local capabilities = lsp.protocol.make_client_capabilities()
  require("cmp_nvim_lsp").update_capabilities(capabilities)

  -- Setting up the servers with the provided configuration and additional
  -- capabilities.
  for server, config in pairs(servers) do
    config = type(config) == "function" and config() or config
    config.on_attach = custom_on_attach
    config.flags = config.flags or {}
    config.flags.debounce_text_changes = 500
    config.capabilities = vim.tbl_deep_extend(
      "keep",
      config.capabilities or {},
      capabilities
    )
    lspconfig[server].setup(config)
  end
end
