-- Ref: https://github.com/neovim/nvim-lspconfig
local lsp = vim.lsp
local map = vim.api.nvim_set_keymap
local buf_map = vim.api.nvim_buf_set_keymap
local create_augroups = require('core.utils').create_augroups
local lspconfig = require('lspconfig')

-- Utiliy functions
function _G.reload_lsp()
  lsp.stop_client(lsp.get_active_clients())
  vim.cmd [[edit]]
end

-- Open the LSP log on the bottom of the tab occupying the full width and
-- height of about 20.
function _G.open_lsp_log()
  local path = lsp.get_log_path()
  vim.cmd("botright split | resize 20 | edit " .. path)
end

vim.cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')
vim.cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')

-- Useful keybindings (Do I even need them?)
map('n', '<Leader>ll', '<Cmd>LspLog<CR>', {noremap = true})
map('n', '<Leader>lr', '<Cmd>LspRestart<CR>', {noremap = true})
map('n', '<Leader>li', '<Cmd>LspInfo<CR>', {noremap = true})

-- Override the default capabilities and pass it to the language server on
-- initialization. E.g., adding snippets supports.
-- TODO: Update server **only** after adding a snippet plugin
local updated_capabilities = lsp.protocol.make_client_capabilities()
updated_capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Default handler to publish diagnostics.
-- NOTE: Instead of virtual_text, we can use `lsp.diagnostic.show_line_diagnostic()`
-- to open a floating window with the diagnostic from {line_nr}.
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    underline = true,
    signs = true,
    update_in_insert = false
  }
)

-- Adding VSCode like icons to the completion menu.
-- vscode-codicons: https://github.com/microsoft/vscode-codicons
require('vim.lsp.protocol').CompletionItemKind = {
  ' ' .. ' Text';          -- = 1
  ' ' .. ' Method';        -- = 2;
  ' ' .. ' Function';      -- = 3;
  ' ' .. ' Constructor';   -- = 4;
  ' ' .. ' Field';         -- = 5;
  ' ' .. ' Variable';      -- = 6;
  ' ' .. ' Class';         -- = 7;
  ' ' .. ' Interface';     -- = 8;
  ' ' .. ' Module';        -- = 9;
  ' ' .. ' Property';      -- = 10;
  ' ' .. ' Unit';          -- = 11;
  ' ' .. ' Value';         -- = 12;
  ' ' .. ' Enum';          -- = 13;
  ' ' .. ' Keyword';       -- = 14;
  ' ' .. ' Snippet';       -- = 15;
  ' ' .. ' Color';         -- = 16;
  ' ' .. ' File';          -- = 17;
  ' ' .. ' Reference';     -- = 18;
  ' ' .. ' Folder';        -- = 19;
  ' ' .. ' EnumMember';    -- = 20;
  ' ' .. ' Constant';      -- = 21;
  ' ' .. ' Struct';        -- = 22;
  ' ' .. ' Event';         -- = 23;
  ' ' .. ' Operator';      -- = 24;
  ' ' .. ' TypeParameter'; -- = 25;
}

-- Just a convenience
local noremap = {noremap = true}

-- The main `on_attach` function to be called by each of the language server
-- to setup the required keybindings and functionalities provided by other
-- plugins.
--
-- This function needs to be passed to every language server. If a language
-- server requires either more config or less, it should also be done in this
-- function using the `filetype` conditions.
local function on_attach(client)
  local lsp_autocmds = {}
  -- For plugins with an `on_attach` callback, call them here.

  -- Used to setup per filetype
  -- local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

  -- Keybindings
  buf_map(0, 'n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', noremap)
  buf_map(0, 'n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', noremap)
  -- Calling the function twice will jump into the floating window.
  buf_map(0, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', noremap)
  buf_map(0, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', noremap)
  buf_map(0, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', noremap)
  buf_map(0, 'n', 'gy', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', noremap)
  buf_map(0, 'n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', noremap)
  buf_map(0, 'n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', noremap)
  buf_map(0, 'n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', noremap)
  buf_map(0, 'n', '<C-s>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', noremap)
  buf_map(0, 'n', '<Leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', noremap)

  -- Setup auto-formatting on save if the language server supports it.
  if client.resolved_capabilities.document_formatting then
    local ext = vim.fn.expand('%:e')
    table.insert(
      lsp_autocmds, 'BufWritePre *.' .. ext .. ' lua vim.lsp.diagnostic.formatting_sync(nil, 100)'
    )
  end

  if client.resolved_capabilities.document_highlight then
    table.insert(lsp_autocmds, 'CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
    -- table.insert(lsp_autocmds, 'CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()')
    table.insert(lsp_autocmds, 'CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
  end

  -- Treesitter is showing the `next` node as an ERROR?
  if next(lsp_autocmds) ~= nil then
    create_augroups({custom_lsp_autocmds = lsp_autocmds})
  end

  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
end

-- TODO: pyright does not provide integration with external tools like mypy,
-- flake8, black, etc., switch to `pyls`?
-- Pyright settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
lspconfig.pyright.setup {
  on_attach = on_attach,
  settings = {
    pyright = {
      disableOrganizeImports = true  -- Using isort
    },
    python = {
      venvPath = os.getenv('HOME') .. '/.pyenv',
      analysis = {
        typeCheckingMode = 'off'  -- Using mypy
      },
    }
  }
}
