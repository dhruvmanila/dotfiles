-- lspconfig: https://github.com/neovim/nvim-lspconfig
-- lightbulb: https://github.com/kosayoda/nvim-lightbulb
-- lspstatus: https://github.com/nvim-lua/lsp-status.nvim
local cmd = vim.api.nvim_command
local lsp = vim.lsp
local map = vim.api.nvim_set_keymap
local sign_define = vim.fn.sign_define
local create_augroups = require('core.utils').create_augroups
local icons = require('core.icons').icons
local kind_icons = require('core.icons').lsp_kind
local lspconfig = require('lspconfig')
local lspstatus = require('lsp-status')
require('pylance')

-- For debugging purposes
-- require('vim.lsp.log').set_level('debug')

---Utiliy functions, commands and keybindings
-- FIXME: this only stops the client
function _G._reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  cmd('edit')
end

function _G._open_lsp_log()
  cmd('botright split')
  cmd('resize 20')
  cmd('edit ' .. lsp.get_log_path())
end

cmd('command! -nargs=0 LspRestart call v:lua._reload_lsp()')
cmd('command! -nargs=0 LspLog call v:lua._open_lsp_log()')

map('n', '<Leader>ll', '<Cmd>LspLog<CR>', {noremap = true})
map('n', '<Leader>lr', '<Cmd>LspRestart<CR>', {noremap = true})
-- map('n', '<Leader>li', '<Cmd>LspInfo<CR>', {noremap = true})

-- Adding VSCode like icons to the completion menu.
-- vscode-codicons: https://github.com/microsoft/vscode-codicons
require('vim.lsp.protocol').CompletionItemKind = (function()
  local items = {}
  for i, info in ipairs(kind_icons) do
    local icon, name = unpack(info)
    items[i] = icon .. '  ' .. name
  end
  return items
end)()

-- Update the default signs
sign_define("LspDiagnosticsSignError", {text = icons.error})
sign_define("LspDiagnosticsSignWarning", {text = icons.warning})
sign_define("LspDiagnosticsSignInformation", {text = icons.info})
sign_define("LspDiagnosticsSignHint", {text = icons.hint})
sign_define("LightBulbSign", {text = icons.lightbulb, texthl = "LspDiagnosticsSignHint"})


---Handlers configuration
-- Can use `lsp.diagnostics.show_line_diagnostic()` instead of `virtual_text`
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    underline = true,
    signs = true,
    update_in_insert = false
  }
)

-- Press 'K' for hover and then 'K' again to enter the hover window.
-- Press 'q' to quit.
lsp.handlers["textDocument/hover"] = function(...)
  local bufnr, _ = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = "single"  -- 'double'
    }
  )(...)

  local opts = {noremap = true, nowait = true, silent = true}
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>quit<CR>', opts)
end

lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "single"
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
  kind_labels = (function()
    local items = {}
    for _, info in ipairs(kind_icons) do
      local icon, name = unpack(info)
      items[name] = icon
    end
    return items
  end)(),
  indicator_errors = icons.error,
  indicator_warnings = icons.warning,
  indicator_info = icons.info,
  indicator_hint = icons.hint,
}
-- Register the progress handler with Neovim's LSP client.
lspstatus.register_progress()


-- The main `on_attach` function to be called by each of the language server
-- to setup the required keybindings and functionalities provided by other
-- plugins.
--
-- This function needs to be passed to every language server. If a language
-- server requires either more config or less, it should also be done in this
-- function using the `filetype` conditions.
local function custom_on_attach(client)
  local opts = {noremap = true}
  local lsp_autocmds = {}

  local function add_autocmds(event, func)
    table.insert(lsp_autocmds, event .. ' <buffer> lua vim.lsp.' .. func)
  end

  local function buf_map(key, func, mode)
    mode = mode or 'n'
    local command = '<Cmd>lua vim.lsp.' .. func .. '<CR>'
    vim.api.nvim_buf_set_keymap(0, mode, key, command, opts)
  end

  -- For plugins with an `on_attach` callback, call them here.
  lspstatus.on_attach(client)

  -- Used to setup per filetype
  -- local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

  -- Keybindings:
  -- For all types of diagnostics: [d | ]d
  -- For warning and error diagnostics: [e | ]e
  buf_map('[d', 'diagnostic.goto_prev({enable_popup = false})')
  buf_map(']d', 'diagnostic.goto_next({enable_popup = false})')
  buf_map('[e', 'diagnostic.goto_prev({enable_popup = false, severity_limit = "Warning"})')
  buf_map(']e', 'diagnostic.goto_next({enable_popup = false, severity_limit = "Warning"})')
  buf_map(';l', 'diagnostic.show_line_diagnostics({show_header = false, border = "single"})')
  -- Calling the function twice will jump into the floating window.
  buf_map('K', 'buf.hover()')
  buf_map('gd', 'buf.definition()')
  buf_map('gD', 'buf.declaration()')
  buf_map('gy', 'buf.type_definition()')
  buf_map('gi', 'buf.implementation()')
  buf_map('gr', 'buf.references()')
  buf_map('<C-s>', 'buf.signature_help()')
  buf_map('<Leader>rn', 'buf.rename()')

  -- Setup auto-formatting on save if the language server supports it.
  if client.resolved_capabilities.document_formatting then
    buf_map('<Leader>lf', 'buf.formatting()')
    -- TODO: auto format setup as per the configuration option b.auto_format_<ft> ?
    -- add_autocmds('BufWritePre', 'buf.formatting_sync(nil, 1000)')
  end

  -- Hl groups: LspReferenceText, LspReferenceRead, LspReferenceWrite
  if client.resolved_capabilities.document_highlight then
    add_autocmds('CursorHold', 'buf.document_highlight()')
    add_autocmds('CursorMoved', 'buf.clear_references()')
    -- add_autocmds('CursorHold', 'diagnostics.show_line_diagnostics({show_header = false})')
  end

  -- TODO: use telescope to display code action or lspsaga?
  if client.resolved_capabilities.code_action then
    cmd('packadd nvim-lightbulb')
    table.insert(
      lsp_autocmds,
      "CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()"
    )
    buf_map('ga', 'buf.code_action()')
  end

  if not vim.tbl_isempty(lsp_autocmds) then
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
    settings = {
      rootMarkers = {'.git/', 'requirements.txt'},
      languages = {
        python = {
          {
            lintCommand = 'mypy --show-column-numbers --follow-imports silent --ignore-missing-imports',
            lintFormats = {
              '%f:%l:%c: %trror: %m',
              '%f:%l:%c: %tarning: %m',
              '%f:%l:%c: %tote: %m',
            },
            lintIgnoreExitCode = true,
          },
          {
            lintCommand = 'flake8 --stdin-display-name ${INPUT} -',
            lintStdin = true,
            lintFormats = {'%f:%l:%c: %m'},
            lintIgnoreExitCode = true,
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

  -- Settings: https://github.com/microsoft/pylance-release#settings-and-customization
  pylance = {
    settings = {
      python = {
        analysis = {
          completeFunctionParens = true,
          typeCheckingMode = 'off',  -- Using mypy
          -- https://github.com/microsoft/pylance-release/issues/1055
          indexing = false,
        }
      }
    }
  },

  -- https://github.com/microsoft/pyright
  -- Settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
  -- pyright = {
  --   settings = {
  --     pyright = {
  --       disableOrganizeImports = true  -- Using isort
  --     },
  --     python = {
  --       venvPath = os.getenv('HOME') .. '/.pyenv',
  --       analysis = {
  --         typeCheckingMode = 'off'  -- Using mypy
  --       },
  --     }
  --   }
  -- },

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
