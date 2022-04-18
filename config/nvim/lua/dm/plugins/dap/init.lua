require 'dm.plugins.dap.extensions'
require 'dm.plugins.dap.adapters'
require 'dm.plugins.dap.configurations'

local dap = require 'dap'

-- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
dap.set_log_level(vim.env.DEBUG and 'debug' or 'warn')

vim.fn.sign_define {
  { name = 'DapStopped', text = '', texthl = '' },
  { name = 'DapLogPoint', text = '', texthl = '' },
  { name = 'DapBreakpoint', text = '', texthl = 'Orange' },
  { name = 'DapBreakpointCondition', text = '', texthl = 'Orange' },
  { name = 'DapBreakpointRejected', text = '', texthl = 'Red' },
}

vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP: Continue' })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step over' })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step into' })
vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'DAP: Step out' })
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, {
  desc = 'DAP: Toggle breakpoint',
})
vim.keymap.set('n', '<leader>dB', function()
  vim.ui.input({ prompt = 'Breakpoint Condition: ' }, function(condition)
    if condition then
      dap.set_breakpoint(condition)
    end
  end)
end, { desc = 'DAP: Set breakpoint with condition' })
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'DAP: Run last' })
vim.keymap.set('n', '<leader>dc', dap.run_to_cursor, {
  desc = 'DAP: Run to cursor',
})
vim.keymap.set('n', '<leader>dx', dap.restart, { desc = 'DAP: Restart' })
vim.keymap.set('n', '<leader>ds', dap.terminate, { desc = 'DAP: Terminate' })
vim.keymap.set('n', '<leader>dr', function()
  dap.repl.toggle { height = math.floor(vim.o.lines * 0.3) }
end, { desc = 'DAP: Toggle repl' })

-- Default command to create a split window when using the integrated terminal.
dap.defaults.fallback.terminal_win_cmd = string.format(
  'belowright %dnew | set winfixheight',
  math.floor(vim.o.lines * 0.3)
)

do
  local id = vim.api.nvim_create_augroup('dm__dap_repl', { clear = true })

  -- REPL completion to trigger automatically on any of the completion trigger
  -- characters reported by the debug adapter or on '.' if none are reported.
  vim.api.nvim_create_autocmd('FileType', {
    group = id,
    pattern = 'dap-repl',
    callback = function(args)
      require('dap.ext.autocompl').attach(args.buf)
    end,
    desc = 'DAP: REPL completion',
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = id,
    pattern = '\\[dap-repl\\]',
    command = 'startinsert',
  })
end

-- Automatically close the DAP repl and terminal buffer, if present.
dap.listeners.before['event_terminated']['dap_repl_terminal'] = function()
  dap.repl.close()
end
dap.listeners.before['event_exited']['dap_repl_terminal'] = function()
  dap.repl.close()
end
