-- lspconfig: https://github.com/neovim/nvim-lspconfig
-- lightbulb: https://github.com/kosayoda/nvim-lightbulb
-- lspstatus: https://github.com/nvim-lua/lsp-status.nvim
local cmd = vim.cmd
local lsp = vim.lsp
local map = vim.api.nvim_set_keymap
local buf_map = vim.api.nvim_buf_set_keymap
local sign_define = vim.fn.sign_define
local create_augroups = require('core.utils').create_augroups
local icons = require('core.icons').icons
local kind_icons = require('core.icons').lsp_kind
local lspconfig = require('lspconfig')
local lspstatus = require('lsp-status')

-- For debugging purposes
-- require('vim.lsp.log').set_level('debug')

---Utiliy functions, commands and keybindings
function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd('edit')
end

function _G.open_lsp_log()
  cmd('botright split')
  cmd('resize 20')
  cmd('edit ' .. lsp.get_log_path())
end

cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')
cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')

map('n', '<Leader>ll', '<Cmd>LspLog<CR>', {noremap = true})
map('n', '<Leader>lr', '<Cmd>LspRestart<CR>', {noremap = true})
map('n', '<Leader>li', '<Cmd>LspInfo<CR>', {noremap = true})

-- Adding VSCode like icons to the completion menu.
-- vscode-codicons: https://github.com/microsoft/vscode-codicons
require('vim.lsp.protocol').CompletionItemKind = (function()
  local items = {}
  for name, icon in pairs(kind_icons) do
    items[#items+1] = icon .. '  ' .. name
  end
  return items
end)()

-- Update the default signs
sign_define("LspDiagnosticsSignError", {text = icons.error})
sign_define("LspDiagnosticsSignWarning", {text = icons.warning})
sign_define("LspDiagnosticsSignInformation", {text = icons.info})
sign_define("LspDiagnosticsSignHint", {text = icons.hint})

---Handlers configuration
-- Using `lsp.diagnostics.show_line_diagnostic()` instead of `virtual_text`
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    underline = true,
    signs = true,
    update_in_insert = false
  }
)


---LSP status configuration
lspstatus.config {
  -- The sumneko lua server sends valueRange (which is not specified in the
  -- protocol) to give the range for a function's start and end.
  select_symbol = function(cursor_pos, symbol)
    if symbol.valueRange then
      local value_range = {
        ["start"] = {
          character = 0,
          line = vim.fn.byte2line(symbol.valueRange[1])
        },
        ["end"] = {
          character = 0,
          line = vim.fn.byte2line(symbol.valueRange[2])
        }
      }
      return require("lsp-status.util").in_range(cursor_pos, value_range)
    end
  end,
  kind_labels = kind_icons,
  indicator_errors = icons.error,
  indicator_warnings = icons.warning,
  indicator_info = icons.info,
  indicator_hint = icons.hint,
  -- TODO
  -- indicator_ok = '',
  -- status_symbol = ''
}
-- Register the progress handler with Neovim's LSP client.
lspstatus.register_progress()

---Lightbulb configuration
create_augroups(
  {
    lsp_lightbulb =
    {"CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()"}
  }
)
sign_define("LightBulbSign", {text = icons.lightbulb, texthl = "LspDiagnosticsSignHint"})


-- The main `on_attach` function to be called by each of the language server
-- to setup the required keybindings and functionalities provided by other
-- plugins.
--
-- This function needs to be passed to every language server. If a language
-- server requires either more config or less, it should also be done in this
-- function using the `filetype` conditions.
local function custom_on_attach(client)
  local noremap = {noremap = true}
  local lsp_autocmds = {}

  -- For plugins with an `on_attach` callback, call them here.
  lspstatus.on_attach(client)

  -- Used to setup per filetype
  -- local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

  -- Keybindings
  buf_map(0, 'n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev({enable_popup = false})<CR>', noremap)
  buf_map(0, 'n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next({enable_popup = false})<CR>', noremap)
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
    buf_map(0, 'n', '<Leader>lf', '<Cmd>lua vim.lsp.buf.formatting()<CR>', noremap)
    -- TODO: auto format setup as per the configuration option b.auto_format_<ft> ?
    -- table.insert(lsp_autocmds, 'BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)')
  end

  if client.resolved_capabilities.document_highlight then
    -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
    table.insert(lsp_autocmds, 'CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
    table.insert(
      lsp_autocmds,
      'CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({show_header = false})'
    )
    table.insert(lsp_autocmds, 'CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
  end

  if next(lsp_autocmds) ~= nil then
    create_augroups({custom_lsp_autocmds = lsp_autocmds})
  end

  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
end


---Server configurations
local servers = {
  -- https://github.com/bash-lsp/bash-language-server
  -- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
  bashls = {},

  -- https://github.com/mattn/efm-langserver
  -- Settings: https://github.com/mattn/efm-langserver/blob/master/schema.json
  efm = {
    -- cmd = {'efm-langserver', '-logfile', '/tmp/efm.log', '-loglevel', '5'},
    init_options = { documentFormatting = true },
    filetypes = {'python'},
    logfile = '/tmp/efm_langserver.log',
    loglevel = 5,
    settings = {
      rootMarkers = {'.git/'},
      languages = {
        python = {
          {
            lintCommand = 'mypy --show-column-numbers --follow-imports silent --ignore-missing-imports',
            lintFormats = {
              '%f:%l:%c: %trror: %m',
              '%f:%l:%c: %tarning: %m',
              '%f:%l:%c: %tote: %m',
            },
          },
          {
            lintCommand = 'flake8 --stdin-display-name ${INPUT} -',
            lintStdin = true,
            lintFormats = {'%f:%l:%c: %m'},
          },
          {
            formatCommand = 'black -',
            formatStdin = true,
          },
          {
            formatCommand = 'isort --profile black -',
            formatStdin = true,
          },
        },
      },
    },
  },

  -- https://github.com/vscode-langservers/vscode-json-languageserver
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#jsonls
  jsonls = {},

  -- https://github.com/microsoft/pyright
  -- Settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
  pyright = {
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
  },

  -- https://github.com/sumneko/lua-language-server
  -- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua
  sumneko_lua = {
    cmd = {
      os.getenv("HOME") .. "/git/lua-language-server/bin/macOS/lua-language-server",
      "-E",
      os.getenv("HOME") .. "/git/lua-language-server/main.lua"
    },
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          enable = true,
          globals = {'vim'},
        },
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          },
          preloadFileSize = 1000,  -- Default: 100
        },
      },
    }
  },

  -- https://github.com/iamcco/vim-language-server
  vimls = {},

  -- https://github.com/redhat-developer/yaml-language-server
  -- Settings: https://github.com/redhat-developer/yaml-language-server#language-server-settings
  yamlls = {},
}

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
  config.on_attach = custom_on_attach
  config.capabilities = vim.tbl_deep_extend(
    'keep',
    config.capabilities or {},
    lspstatus.capabilities
  )
  lspconfig[server].setup(config)
end
