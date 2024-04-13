-- Client side extensions for `ruff_lsp` language server.
local M = {}

local utils = require 'dm.utils'

local function execute_command(command_name)
  utils.get_client('ruff_lsp').request(vim.lsp.protocol.Methods.workspace_executeCommand, {
    command = command_name,
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

-- Setup the buffer local commands for the `ruff_lsp` extension features.
---@param bufnr number
function M.on_attach(bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, 'RuffApplyAutofix', apply_autofix, {
    desc = 'Ruff: Fix all auto-fixable problems',
  })
  vim.api.nvim_buf_create_user_command(bufnr, 'RuffOrganizeImports', apply_organize_imports, {
    desc = 'Ruff: Format imports',
  })
  vim.api.nvim_buf_create_user_command(bufnr, 'RuffFormat', apply_format, {
    desc = 'Ruff: Format document',
  })
end

return M
