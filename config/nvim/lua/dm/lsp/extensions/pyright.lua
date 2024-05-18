-- Client side extensions for `pyright` language server.
local M = {}

local utils = require 'dm.utils'

-- Available debug info kinds.
local DEBUG_INFO_KINDS = {
  'tokens',
  'nodes',
  'types',
  'cachedtypes',
  'codeflowgraph',
}

-- See: https://github.com/microsoft/pyright/blob/556608dffddd8026f109aa1739b3c4dcaf2757f6/packages/pyright-internal/src/commands/dumpFileDebugInfoCommand.ts
---@param kind string
local function dump_file_debug_info(kind)
  -- The server sends this information via the `window/logMessage` method at `Info` level.
  -- Set the LSP log level temporarily to `INFO` level to log the information.
  local current_lsp_log_level = vim.lsp.log.get_level()
  vim.lsp.set_log_level(vim.log.levels.INFO)

  utils.get_client('pyright').request(vim.lsp.protocol.Methods.workspace_executeCommand, {
    command = 'pyright.dumpFileDebugInfo',
    arguments = { vim.uri_from_bufnr(0), kind },
  }, function()
    vim.cmd.tabedit(vim.fs.joinpath(vim.fn.stdpath 'log', 'lsp.pyright.log'))
    vim.keymap.set('n', 'q', '<Cmd>quit<CR>', { buffer = true })
    -- Reset the log level to what it was earlier.
    vim.lsp.set_log_level(current_lsp_log_level)
  end)
end

-- Setup the buffer local commands for the `pyright` extension features.
---@param _ vim.lsp.Client
---@param bufnr number
function M.on_attach(_, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, 'PyrightDumpFileDebugInfo', function(data)
    dump_file_debug_info(data.fargs[1])
  end, {
    nargs = 1,
    complete = function(arglead)
      return vim
        .iter(DEBUG_INFO_KINDS)
        :filter(function(kind)
          return kind:match(arglead)
        end)
        :totable()
    end,
    desc = 'pyright: dump file debug info',
  })
end

return M
