local dap = require 'dap'

dap.adapters.lldb = {
  name = 'lldb',
  type = 'executable',
  command = 'lldb-vscode',
}

do
  -- Returns the path to the VS Code LLDB extension under `~/.vscode/extensions`.
  ---@return string?
  local function vscode_lldb_extension_path()
    local extensions_dir = vim.fs.normalize '~/.vscode/extensions'
    for name, type in vim.fs.dir(extensions_dir) do
      if type == 'directory' and name:match '.+vscode%-lldb.+' ~= nil then
        return vim.fs.joinpath(extensions_dir, name)
      end
    end
  end

  local extension_path = vscode_lldb_extension_path()
  if extension_path == nil then
    vim.notify_once('VSCode LLDB extension not found', vim.log.levels.WARN)
  else
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
  if dm.log.should_log(dm.log.levels.DEBUG) then
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
