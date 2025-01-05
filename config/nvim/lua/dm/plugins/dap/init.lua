return {
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'DAP: Continue',
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
        desc = 'DAP: Step over',
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
        desc = 'DAP: Step into',
      },
      {
        '<F12>',
        function()
          require('dap').step_out()
        end,
        desc = 'DAP: Step out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'DAP: Toggle breakpoint',
      },
      {
        '<leader>dB',
        function()
          vim.ui.input({ prompt = 'Breakpoint Condition: ' }, function(condition)
            if condition then
              require('dap').set_breakpoint(condition)
            end
          end)
        end,
        desc = 'DAP: Set breakpoint with condition',
      },
      {
        '<leader>dl',
        function()
          require('dap').run_last()
        end,
        desc = 'DAP: Run last',
      },
      {
        '<leader>dc',
        function()
          require('dap').run_to_cursor()
        end,
        desc = 'DAP: Run to cursor',
      },
      {
        '<leader>dx',
        function()
          require('dap').restart()
        end,
        desc = 'DAP: Restart',
      },
      {
        '<leader>ds',
        function()
          require('dap').terminate()
        end,
        desc = 'DAP: Terminate',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle { height = math.floor(vim.o.lines * 0.3) }
        end,
        desc = 'DAP: Toggle repl',
      },
    },
    dependencies = {
      'mfussenegger/nvim-dap-python',
      {
        'rcarriga/nvim-dap-ui',
        dependencies = {
          'nvim-neotest/nvim-nio',
        },
        opts = {
          mappings = {
            expand = { '<CR>', '<2-LeftMouse>', '<Tab>' },
          },
          layouts = {
            {
              size = 0.35,
              position = 'left',
              elements = {
                { id = 'scopes', size = 0.6 },
                { id = 'watches', size = 0.2 },
                { id = 'breakpoints', size = 0.2 },
              },
            },
          },
          floating = {
            border = dm.border,
          },
        },
      },
      { 'theHamsta/nvim-dap-virtual-text', config = true },
    },
    config = function()
      require 'dm.plugins.dap.adapters'
      require 'dm.plugins.dap.configurations'

      local dap = require 'dap'
      local dapui = require 'dapui'
      local dap_python = require 'dap-python'

      -- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
      dap.set_log_level(dm.log.get_level_name())

      -- Load VSCode configurations from `./.vscode/launch.json` file.
      --
      -- Note: This should come after adding custom configurations as it *extends*
      -- it. If there's a configuration with the same name, it'll *override* it.
      local ok, err = pcall(require('dap.ext.vscode').load_launchjs, nil, {
        lldb = { 'rust' },
      })
      if not ok then
        vim.schedule(function()
          dm.notify('nvim-dap', {
            'Error while loading VSCode launch configuration:',
            '',
            tostring(err),
          }, vim.log.levels.WARN)
        end)
      end

      vim.fn.sign_define {
        { name = 'DapStopped', text = '', texthl = '' },
        { name = 'DapLogPoint', text = '', texthl = '' },
        { name = 'DapBreakpoint', text = '', texthl = 'Orange' },
        { name = 'DapBreakpointCondition', text = '', texthl = 'Orange' },
        { name = 'DapBreakpointRejected', text = '', texthl = 'Red' },
      }

      -- Default command to create a split window when using the integrated terminal.
      dap.defaults.fallback.terminal_win_cmd =
        string.format('belowright %dnew | set winfixheight', math.floor(vim.o.lines * 0.3))

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

      -- Automatically open and close the DAP windows.
      dap.listeners.after['event_initialized']['dap_windows'] = function()
        dapui.open()
      end
      dap.listeners.before['event_terminated']['dap_windows'] = function()
        dap.repl.close()
        dapui.close()
      end
      dap.listeners.before['event_exited']['dap_windows'] = function()
        dapui.close()
        dap.repl.close()
      end

      -- DAP extension for Python. Filetype specific mappings are defined in
      --    `./config/nvim/after/ftplugin/python.lua`
      dap_python.setup('uv', {
        -- We will define the configuration ourselves for additional config options.
        include_configs = false,
      })
      dap_python.test_runner = 'pytest'
    end,
  },
}
