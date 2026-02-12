-- Client side extensions for `ty` language server.
local M = {}

local logger = dm.log.get_logger 'lsp.ty'

local utils = require 'dm.utils'

-- Send a request to the server with the `name` to execute the `command`.
local function print_debug_information(command)
  local bufnr = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({
    bufnr = bufnr,
    name = 'ty',
    method = 'workspace/executeCommand',
  })[1]
  if client == nil then
    logger.debug('No ty client found for buffer %d', bufnr)
    return
  end

  client:request('workspace/executeCommand', {
    command = command,
  }, function(err, result)
    if err ~= nil then
      logger.error('Failed to execute workspace command (%s): %s', command, err.message)
      return
    end
    utils.temp_buffer('ty-debug-info', result)
  end)
end

-- Setup the buffer local commands for the `ty` extension features.
---@param _ vim.lsp.Client
---@param bufnr number
function M.on_attach(_, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, 'TyPrintDebugInformation', function()
    print_debug_information 'ty.printDebugInformation'
  end, {
    desc = 'ty: Print debug information',
  })
end

return M
