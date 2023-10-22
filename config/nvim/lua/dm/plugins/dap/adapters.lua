local dap = require 'dap'

dap.adapters.lldb = {
  name = 'lldb',
  type = 'executable',
  command = 'lldb-vscode',
}

do
  local extension_path = vim.fs.normalize '~/.vscode/extensions/vadimcn.vscode-lldb-1.9.2'
  local codelldb_path = extension_path .. '/adapter/codelldb'
  local liblldb_path = extension_path .. '/lldb/lib/liblldb.dylib'

  -- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)
  -- Settings: https://github.com/vadimcn/codelldb/blob/master/MANUAL.md
  dap.adapters.codelldb = {
    name = 'codelldb',
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = {
      command = codelldb_path,
      args = { '--liblldb', liblldb_path, '--port', '${port}' },
    },
  }
end

-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
dap.adapters.go = function(callback)
  local port = 38697
  local cmd = {
    'dlv',
    'dap',
    '--listen',
    '127.0.0.1:' .. port,
  }
  if dm.current_log_level == dm.log.levels.DEBUG then
    vim.list_extend(cmd, {
      '--log',
      '--log-dest',
      vim.fn.stdpath 'cache' .. '/delve.log',
      '--log-output',
      'dap',
    })
  end
  vim.system(
    cmd,
    {
      detach = true,
      stdout = function(_, data)
        -- Wait for nvim-dap to initiate
        vim.defer_fn(function()
          require('dap.repl').append(data)
        end, 200)
      end,
    },
    ---@param result vim.SystemCompleted
    function(result)
      if result.code ~= 0 then
        dm.notify('DAP (Go adapter - delve)', 'dlv exited with code: ' .. result.code, 4)
      end
    end
  )
  -- Wait for delve to start
  vim.defer_fn(function()
    callback { type = 'server', host = '127.0.0.1', port = port }
  end, 100)
end
