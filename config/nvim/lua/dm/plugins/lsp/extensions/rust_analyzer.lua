-- Client side extension for `rust-analyzer`.
local M = {}

local job = require 'dm.job'
local log = require 'dm.log'

-- Refer: https://github.com/rust-lang/rust-analyzer/blob/master/editors/code/src/lsp_ext.ts#L139

---@class CargoRunnableArgs
---@field cargoArgs string[]
---@field cargoExtraArgs string[]
---@field executableArgs string[]
---@field workspaceRoot string?

---@class CargoRunnable
---@field label string
---@field kind 'cargo'
---@field args CargoRunnableArgs

local cache = {
  -- Bufnr for the latest executed command.
  ---@type number?
  bufnr = nil,

  -- Last runnable.
  ---@type CargoRunnable?
  runnable = nil,
}

-- Spawns the command in a new terminal opened in a horizontal split at
-- the bottom.
--
-- This uses `vim.fn.termopen` to run the command.
--
-- Keybindings:
--    `q`: Quit the terminal window
---@param cmd string
---@param args string[]
---@param cwd string
local function execute_command(cmd, args, cwd)
  if cache.bufnr and vim.api.nvim_buf_is_valid(cache.bufnr) then
    vim.api.nvim_buf_delete(cache.bufnr, { force = true })
  end
  cache.bufnr = vim.api.nvim_create_buf(false, true)

  vim.cmd.split()
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), cache.bufnr)
  vim.cmd.resize(-5)
  vim.api.nvim_buf_set_keymap(cache.bufnr, 'n', 'q', '<Cmd>q<CR>', {
    noremap = true,
  })

  vim.cmd.stopinsert()
  vim.fn.termopen(('%s %s'):format(cmd, table.concat(args, ' ')), {
    cwd = cwd,
  })

  vim.api.nvim_buf_attach(cache.bufnr, false, {
    on_detach = function()
      cache.bufnr = nil
    end,
  })
end

-- Execute Cargo runnable.
---@param runnable CargoRunnable
local function execute_runnable(runnable)
  local args = vim.tbl_flatten {
    runnable.args.cargoArgs,
    runnable.args.cargoExtraArgs,
    '--',
    runnable.args.executableArgs,
  }
  execute_command('cargo', args, runnable.args.workspaceRoot)
end

-- Return the absolute path to the closest Cargo crate directory.
---@return string?
local function cargo_crate_dir()
  return vim.fs.dirname(vim.fs.find('Cargo.toml', {
    upward = true,
    type = 'file',
    stop = vim.loop.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })[1])
end

-- Start the debugging session for the given runnable spec.
--
-- This is used to execute the `rust-analyzer.debugSingle` command.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/editors/code/src/toolchain.ts
---@param runnable CargoRunnable
local function debug_runnable(runnable)
  -- This creates a copy to avoid mutating the original table.
  local cargo_args =
    vim.tbl_flatten { runnable.args.cargoArgs, '--message-format=json' }
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
    cwd = runnable.args.workspaceRoot,
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
        return
      elseif #executables > 1 then
        dm.notify(
          'Rust',
          'Multiple compilation artifacts are not supported',
          vim.log.levels.ERROR
        )
        return
      end

      local dap_config = {
        name = 'Debug ' .. runnable.label,
        type = 'codelldb',
        request = 'launch',
        program = executables[1],
        args = runnable.args.executableArgs or {},
        cwd = cargo_crate_dir() or runnable.args.workspaceRoot,
        console = 'internalConsole',
        stopOnEntry = false,
      }
      log.fmt_info('Launching DAP with config: %s', dap_config)
      require('dap').run(dap_config)
    end,
  }
end

vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
  execute_runnable(command.arguments[1])
end

vim.lsp.commands['rust-analyzer.debugSingle'] = function(command)
  debug_runnable(command.arguments[1])
end

vim.lsp.commands['rust-analyzer.gotoLocation'] = function(command, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  vim.lsp.util.jump_to_location(command.arguments[1], client.offset_encoding)
end

vim.lsp.commands['rust-analyzer.showReferences'] = function()
  vim.lsp.buf.implementation()
end

function M.runnables()
  vim.lsp.buf_request(0, 'experimental/runnables', {
    textDocument = vim.lsp.util.make_text_document_params(0),
    position = nil,
  }, function(_, runnables)
    if runnables == nil then
      return
    end
    ---@cast runnables CargoRunnable[]

    vim.ui.select(runnables, {
      prompt = 'Runnables',
      kind = 'rust-analyzer/runnables',
      format_item = function(runnable)
        return runnable.label
      end,
    }, function(runnable)
      cache.runnable = runnable
      execute_runnable(runnable)
    end)
  end)
end

function M.execute_last_runnable()
  if cache.runnable then
    execute_runnable(cache.runnable)
  else
    M.runnables()
  end
end

return M
