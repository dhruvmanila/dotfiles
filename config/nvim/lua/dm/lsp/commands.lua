-- Client side commands.

local job = require 'dm.job'
local log = require 'dm.log'

---@class CargoRunnableArgs
---@field cargoArgs string[]
---@field cargoExtraArgs string[]
---@field executableArgs string[]
---@field workspaceRoot string

local execute_command

do
  ---@type number?
  local bufnr

  -- Spawns the command in a new terminal opened in a horizontal split at
  -- the bottom.
  --
  -- This uses `vim.fn.termopen` to run the command.
  --
  -- Keybindings:
  --    `q`: Quit the terminal window
  execute_command = function(cmd, args, cwd)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    bufnr = vim.api.nvim_create_buf(false, true)

    vim.cmd.split()
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), bufnr)
    vim.cmd.resize(-5)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>q<CR>', {
      noremap = true,
    })

    vim.cmd.stopinsert()
    vim.fn.termopen(('%s %s'):format(cmd, table.concat(args, ' ')), {
      cwd = cwd,
    })

    vim.api.nvim_buf_attach(bufnr, false, {
      on_detach = function()
        bufnr = nil
      end,
    })
  end
end

---@param args CargoRunnableArgs
---@return string[] #List of all the arguments
---@return string #Workspace root as reported by the LSP server
local function extract_from_args(args)
  return vim.tbl_flatten {
    args.cargoArgs,
    args.cargoExtraArgs,
    '--',
    args.executableArgs,
  },
    args.workspaceRoot
end

-- Start the debugging session from the given `args`.
--
-- This is used to execute the `rust-analyzer.debugSingle` command.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/editors/code/src/toolchain.ts
---@param args CargoRunnableArgs
local function start_debugging_from_args(args)
  local cargo_args = vim.tbl_flatten { args.cargoArgs, '--message-format=json' }
  if cargo_args[1] == 'run' then
    cargo_args[1] = 'build'
  elseif cargo_args[1] == 'test' then
    if not vim.list_contains(cargo_args, '--no-run') then
      table.insert(cargo_args, '--no-run')
    end
  end

  dm.notify(
    'Rust',
    'Compiling a debug build for debugging. This might take some time...'
  )

  job {
    cmd = 'cargo',
    args = cargo_args,
    cwd = args.workspaceRoot,
    on_exit = function(result)
      if result.code > 0 then
        dm.notify(
          'Rust',
          'An error occurred while compiling:\n' .. result.stderr,
          vim.log.levels.ERROR
        )
        return
      end

      local executables = {}
      for _, value in
        ipairs(vim.split(result.stdout, '\n', { trimempty = true }))
      do
        local artifact = vim.json.decode(value, { luanil = { object = true } })
        ---@cast artifact table
        if artifact.reason == 'compiler-artifact' and artifact.executable then
          local is_binary =
            vim.list_contains(artifact.target.crate_types, 'bin')
          local is_build_script =
            vim.list_contains(artifact.target.kind, 'custom-build')
          if
            (cargo_args[1] == 'build' and is_binary and not is_build_script)
            or (cargo_args[1] == 'test' and artifact.profile.test)
          then
            table.insert(executables, artifact.executable)
          end
        end
      end

      if #executables == 0 then
        dm.notify('Rust', 'No compilation artifacts', vim.log.levels.ERROR)
      elseif #executables > 1 then
        dm.notify(
          'Rust',
          'Multiple compilation artifacts are not supported',
          vim.log.levels.ERROR
        )
      end

      local dap_config = {
        name = 'Rust: Debug',
        type = 'lldb',
        request = 'launch',
        program = executables[1],
        args = args.executableArgs or {},
        cwd = args.workspaceRoot,
        stopOnEntry = false,
      }
      log.fmt_info('Launching DAP with config: %s', dap_config)
      require('dap').run(dap_config)
    end,
  }
end

vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
  local args, cwd = extract_from_args(command.arguments[1].args)
  log.fmt_debug('[%s] args=%s cwd=%s', command.command, args, cwd)
  execute_command('cargo', args, cwd)
end

vim.lsp.commands['rust-analyzer.debugSingle'] = function(command)
  start_debugging_from_args(command.arguments[1].args)
end
