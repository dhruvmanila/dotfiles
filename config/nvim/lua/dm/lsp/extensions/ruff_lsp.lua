-- Client side extensions for `ruff_lsp` language server.
local M = {}

local utils = require 'dm.utils'

-- Send a request to the `ruff_lsp` server to execute the given command.
---@param command string
local function execute_command(command)
  utils.get_client('ruff_lsp').request(vim.lsp.protocol.Methods.workspace_executeCommand, {
    command = command,
    arguments = {
      { uri = vim.uri_from_bufnr(0) },
    },
  })
end

local function apply_autofix()
  execute_command 'ruff.applyAutofix'
end

local function apply_organize_imports()
  execute_command 'ruff.applyOrganizeImports'
end

local function apply_format()
  execute_command 'ruff.applyFormat'
end

-- List of user commands to be defined on server attach.
---@type { [1]: string, [2]: function, desc: string }[]
local commands = {
  { 'RuffApplyAutofix', apply_autofix, desc = 'fix all auto-fixable problems' },
  { 'RuffOrganizeImports', apply_organize_imports, desc = 'format imports' },
  { 'RuffFormat', apply_format, desc = 'format document' },
}

-- Setup the buffer local commands for the `ruff_lsp` extension features.
---@param client vim.lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
  client.server_capabilities.hoverProvider = false

  for _, c in ipairs(commands) do
    vim.api.nvim_buf_create_user_command(bufnr, c[1], c[2], { desc = 'ruff: ' .. c.desc })
  end
end

return M
