-- Client side extensions for `ruff`/`ruff_lsp` language server.
local M = {}

local utils = require 'dm.utils'

---@alias RuffServerName 'ruff'|'ruff_lsp'

---@type RuffServerName
local client_name = 'ruff_lsp'

---@param name string
local function set_client_name(name)
  assert(vim.tbl_contains({ 'ruff', 'ruff_lsp' }, name))
  client_name = name
end

-- Send a request to the `ruff_lsp` server to execute the given command.
---@param command string
---@param handler? function
local function execute_command(command, handler)
  local bufnr = vim.api.nvim_get_current_buf()
  utils.get_client(client_name).request(vim.lsp.protocol.Methods.workspace_executeCommand, {
    command = command,
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = assert(
          vim.lsp.util.buf_versions[bufnr],
          ('No version found for buffer %d'):format(bufnr)
        ),
      },
    },
  }, handler)
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

local function print_debug_information()
  local current_lsp_log_level = vim.lsp.log.get_level()
  vim.lsp.set_log_level(vim.log.levels.INFO)

  execute_command('ruff.printDebugInformation', function()
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.cmd.tabedit(vim.fs.joinpath(vim.fn.stdpath 'log', 'lsp.ruff.log'))
    vim.keymap.set('n', 'q', '<Cmd>quit<CR>', { buffer = true })
    vim.lsp.set_log_level(current_lsp_log_level)
  end)
end

-- List of user commands to be defined on server attach.
---@type { [1]: string, [2]: function, desc: string }[]
local commands = {
  { 'RuffApplyAutofix', apply_autofix, desc = 'fix all auto-fixable problems' },
  { 'RuffOrganizeImports', apply_organize_imports, desc = 'format imports' },
  { 'RuffFormat', apply_format, desc = 'format document' },
}

-- Setup the buffer local commands for the `ruff`/`ruff_lsp` extension features.
---@param client vim.lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
  set_client_name(client.name)

  client.server_capabilities.hoverProvider = false

  for _, c in ipairs(commands) do
    vim.api.nvim_buf_create_user_command(bufnr, c[1], c[2], { desc = 'ruff: ' .. c.desc })
  end

  if client.name == 'ruff' then
    -- Only available in the new server
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'RuffPrintDebugInformation',
      print_debug_information,
      { desc = 'ruff: print debug information' }
    )
  end
end

return M
