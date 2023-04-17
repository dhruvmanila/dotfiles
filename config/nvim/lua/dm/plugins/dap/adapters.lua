local dap = require 'dap'
local job = require 'dm.job'

dap.adapters.lldb = {
  name = 'lldb',
  type = 'executable',
  command = 'lldb-vscode',
}

---@see https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
dap.adapters.go = function(callback)
  local port = 38697
  job {
    cmd = 'dlv',
    args = function()
      local args = { 'dap', '--listen', '127.0.0.1:' .. port }
      if dm.current_log_level == dm.log.levels.DEBUG then
        vim.list_extend(args, {
          '--log',
          '--log-dest',
          vim.fn.stdpath 'cache' .. '/delve.log',
          '--log-output',
          'dap',
        })
      end
      return args
    end,
    detached = true,
    on_stdout = function(chunk)
      -- Wait for nvim-dap to initiate
      vim.defer_fn(function()
        require('dap.repl').append(chunk:gsub('\n$', ''))
      end, 200)
    end,
    on_exit = function(result)
      if result.code ~= 0 then
        dm.notify(
          'DAP (Go adapter - delve)',
          'dlv exited with code: ' .. result.code,
          4
        )
      end
    end,
  }
  -- Wait for delve to start
  vim.defer_fn(function()
    callback { type = 'server', host = '127.0.0.1', port = port }
  end, 100)
end
