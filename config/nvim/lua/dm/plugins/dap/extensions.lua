local dap = require 'dap'
local dapui = require 'dapui'
local dap_python = require 'dap-python'

-- Automatically open and close the DAP UI.
dap.listeners.after['event_initialized']['dap_ui'] = function()
  dapui.open()
end
dap.listeners.before['event_terminated']['dap_ui'] = function()
  dapui.close()
end
dap.listeners.before['event_exited']['dap_ui'] = function()
  dapui.close()
end

-- DAP extension for Python.
--
-- Filetype specific mappings are defined in the respective ftplugin file.
dap_python.setup(vim.loop.os_homedir() .. '/.neovim/.venv/bin/python', {
  -- We will define the configuration ourselves for additional config options.
  include_configs = false,
})
dap_python.test_runner = 'pytest'

-- UI Config
dapui.setup {
  mappings = {
    expand = { '<CR>', '<2-LeftMouse>', '<Tab>' },
  },
  layouts = {
    {
      size = math.floor(vim.o.columns * 0.4),
      position = 'left',
      elements = {
        { id = 'scopes', size = 0.7 },
        { id = 'breakpoints', size = 0.3 },
      },
    },
  },
  floating = {
    border = dm.border[vim.g.border_style],
  },
}

require('nvim-dap-virtual-text').setup()
