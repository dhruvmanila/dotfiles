-- Client side extensions for `rust-analyzer` language server.
local M = {}

local log = require 'dm.log'
local utils = require 'dm.utils'

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

---@class ExpandedMacro
---@field name string
---@field expansion string

---@class ExternalDocsResponse
---@field web string?
---@field local string?

local cache = {
  -- Bufnr for the latest executed command.
  ---@type number?
  run_single_bufnr = nil,

  -- Bufnr for the latest expanded macro output.
  ---@type number?
  expand_macro_bufnr = nil,

  -- Last runnable.
  ---@type CargoRunnable?
  runnable = nil,
}

-- Delete the buffer if it exists.
---@param bufnr number?
local function delete_bufnr(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Format the macro expansion output.
---@param macro ExpandedMacro
---@return string[]
local function format_macro_expansion(macro)
  local header = ('// Rescursive expansion of `%s` macro:'):format(macro.name)
  return vim.tbl_flatten {
    header,
    '// ' .. string.rep('=', #header - 3),
    '',
    '',
    vim.split(macro.expansion, '\n', { plain = true }),
  }
end

-- Spawns the command in a new terminal opened in a horizontal split at the bottom.
--
-- Implementation behavior:
-- - Uses the `vim.fn.termopen` function to run the command.
-- - The buffer is scrolled to the bottom on every new line.
-- - The cursor is moved to the bottom for the first time the buffer is entered.
--
-- Keybindings:
--    `q`: Quit the terminal window
---@param cmd string #Command to execute.
---@param args string[] #Arguments to pass to the command.
---@param cwd string #Current working directory for the command.
local function execute_command(cmd, args, cwd)
  local original_winnr = vim.api.nvim_get_current_win()
  delete_bufnr(cache.run_single_bufnr)
  cache.run_single_bufnr = vim.api.nvim_create_buf(false, true)

  vim.cmd.split()
  local terminal_winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(terminal_winnr, cache.run_single_bufnr)
  vim.cmd.resize(math.ceil(vim.o.lines * 0.35))

  local job_id = vim.fn.termopen(('%s %s'):format(cmd, table.concat(args, ' ')), {
    cwd = cwd,
  })
  vim.api.nvim_set_current_win(original_winnr)

  vim.api.nvim_buf_set_keymap(cache.run_single_bufnr, 'n', 'q', '', {
    callback = function()
      vim.fn.jobstop(job_id)
      delete_bufnr(cache.run_single_bufnr)
    end,
    noremap = true,
  })

  vim.api.nvim_buf_attach(cache.run_single_bufnr, false, {
    on_lines = function(_, bufnr)
      vim.api.nvim_win_set_cursor(terminal_winnr, { vim.api.nvim_buf_line_count(bufnr), 0 })
    end,
    on_detach = function()
      cache.run_single_bufnr = nil
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = cache.run_single_bufnr,
    once = true,
    callback = function(event)
      vim.api.nvim_win_set_cursor(terminal_winnr, { vim.api.nvim_buf_line_count(event.buf), 0 })
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
    stop = vim.g.os_homedir,
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
  local cargo_args = vim.tbl_flatten { runnable.args.cargoArgs, '--message-format=json' }
  if cargo_args[1] == 'run' then
    cargo_args[1] = 'build'
  elseif cargo_args[1] == 'test' then
    if not vim.list_contains(cargo_args, '--no-run') then
      table.insert(cargo_args, '--no-run')
    end
  end

  dm.notify('Rust', 'Compiling a debug build for debugging. This might take some time...', nil, {
    timeout = false,
  })

  vim.system(
    vim.tbl_flatten { 'cargo', cargo_args },
    { cwd = runnable.args.workspaceRoot },
    ---@param result vim.SystemCompleted
    vim.schedule_wrap(function(result)
      require('notify').dismiss()
      if result.code > 0 then
        dm.notify(
          'Rust',
          'An error occurred while compiling:\n' .. result.stderr,
          vim.log.levels.ERROR
        )
        return
      end
      dm.notify('Rust', 'Compilation successful')

      local executables = {}
      for _, value in ipairs(vim.split(result.stdout or '', '\n', { trimempty = true })) do
        local artifact = vim.json.decode(value, { luanil = { object = true } })
        ---@cast artifact table
        if artifact.reason == 'compiler-artifact' and artifact.executable then
          local is_binary = vim.list_contains(artifact.target.crate_types, 'bin')
          local is_build_script = vim.list_contains(artifact.target.kind, 'custom-build')
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
        dm.notify('Rust', 'Multiple compilation artifacts are not supported', vim.log.levels.ERROR)
        return
      end

      local args = runnable.args.executableArgs
      if vim.tbl_isempty(args) then
        args = utils.ask_for_arguments()
      end

      local dap_config = {
        name = 'Debug ' .. runnable.label,
        type = 'codelldb',
        request = 'launch',
        program = executables[1],
        args = args,
        cwd = cargo_crate_dir() or runnable.args.workspaceRoot,
        console = 'internalConsole',
        stopOnEntry = false,
      }
      log.fmt_info('Launching DAP with config: %s', dap_config)
      require('dap').run(dap_config)
    end)
  )
end

-- Show a list of runnables and execute the selected one. This uses the `vim.ui.select` function
-- to provide a list of runnables for the user to choose from.
local function runnables()
  utils.get_client('rust_analyzer').request('experimental/runnables', {
    textDocument = vim.lsp.util.make_text_document_params(0),
    position = nil,
  }, function(_, result)
    if result == nil then
      return
    end
    ---@cast result CargoRunnable[]

    vim.ui.select(result, {
      prompt = 'Runnables',
      kind = 'rust-analyzer/runnables',
      format_item = function(runnable)
        return runnable.label
      end,
    }, function(runnable)
      if runnable then
        cache.runnable = runnable
        execute_runnable(runnable)
      end
    end)
  end)
end

-- Execute the last runnable if there is one, otherwise show the list of runnables to execute.
local function execute_last_runnable()
  if cache.runnable then
    execute_runnable(cache.runnable)
  else
    runnables()
  end
end

-- Implementation for viewing the crate graph.
---@param full boolean #If true, include all crates, not just crates in the workspace.
local function view_crate_graph_impl(full)
  utils
    .get_client('rust_analyzer')
    .request('rust-analyzer/viewCrateGraph', { full = full }, function(err, graph)
      if err ~= nil then
        dm.notify('rust-analyzer', tostring(err), vim.log.levels.ERROR)
        return
      end

      local notification =
        dm.notify('rust-analyzer', 'Processing crate graph. This may take a while...')

      -- TODO(dhruvmanila): Make layout engine and output format as an argument?
      -- Layout engines: https://graphviz.org/docs/layouts/
      -- Output formats: https://graphviz.org/docs/outputs/
      vim.system(
        { 'dot', '-Tsvg' },
        { stdin = graph },
        ---@param result vim.SystemCompleted
        function(result)
          if result.code > 0 then
            dm.notify(
              'rust-analyzer',
              'Failed to process crate graph:\n\n' .. result.stderr,
              vim.log.levels.ERROR,
              { replace = notification }
            )
            return
          end

          local tmpfile = vim.fs.joinpath(vim.fn.stdpath 'run', 'rust_analyzer_crate_graph.svg')
          local file = assert(io.open(tmpfile, 'w+'))
          file:write(result.stdout)
          file:flush()
          file:close()

          os.execute(vim.g.open_command .. ' ' .. tmpfile)
        end
      )
    end)
end

-- View the full crate graph. This includes all the crates, not just the ones in the workspace.
local function view_crate_graph_full()
  view_crate_graph_impl(true)
end

-- View the crate graph.
local function view_crate_graph()
  view_crate_graph_impl(false)
end

-- Trigger the flycheck process for the current buffer.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#controlling-flycheck
local function run_flycheck()
  utils.get_client('rust_analyzer').notify('rust-analyzer/runFlycheck', {
    textDocument = vim.lsp.util.make_text_document_params(),
  })
end

-- Cancel all the running flycheck processes.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#controlling-flycheck
local function cancel_flycheck()
  utils.get_client('rust_analyzer').notify 'rust-analyzer/cancelFlycheck'
end

-- Clears all the flycheck diagnostics.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#controlling-flycheck
local function clear_flycheck()
  utils.get_client('rust_analyzer').notify 'rust-analyzer/clearFlycheck'
end

-- Expand the macro under the cursor recursively and show the output in a new buffer.
local function expand_macro_recursively()
  utils.get_client('rust_analyzer').request(
    'rust-analyzer/expandMacro',
    vim.lsp.util.make_position_params(),
    ---@param expanded ExpandedMacro
    function(_, expanded)
      if expanded == nil then
        dm.notify('Rust', 'No macro under cursor', vim.log.levels.WARN)
        return
      end

      delete_bufnr(cache.expand_macro_bufnr)
      cache.expand_macro_bufnr = vim.api.nvim_create_buf(false, true)
      vim.cmd.split()
      vim.api.nvim_win_set_buf(0, cache.expand_macro_bufnr)
      vim.cmd.resize(math.ceil(vim.o.lines * 0.3))
      vim.api.nvim_buf_set_keymap(cache.expand_macro_bufnr, 'n', 'q', '<Cmd>q<CR>', {
        noremap = true,
      })
      vim.api.nvim_set_option_value('filetype', 'rust', { buf = cache.expand_macro_bufnr })
      vim.api.nvim_buf_set_lines(
        cache.expand_macro_bufnr,
        0,
        0,
        false,
        format_macro_expansion(expanded)
      )
      -- Move cursor to the start of the macro expansion.
      vim.api.nvim_win_set_cursor(0, { 5, 0 })
    end
  )
end

-- Open the documentation for the symbol under the cursor.
--
-- This assumes that the `localDocs` experimental feature is enabled.
local function open_external_docs()
  utils.get_client('rust_analyzer').request(
    'experimental/externalDocs',
    vim.lsp.util.make_position_params(),
    ---@param result ExternalDocsResponse
    function(_, result)
      local url = result['local'] or result.web
      if url == nil then
        dm.notify('Rust', 'No documentation found', vim.log.levels.WARN)
        return
      end
      vim.ui.open(url)
    end
  )
end

vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
  execute_runnable(command.arguments[1])
end

vim.lsp.commands['rust-analyzer.debugSingle'] = function(command)
  debug_runnable(command.arguments[1])
end

vim.lsp.commands['rust-analyzer.gotoLocation'] = function(command, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client == nil then
    return
  end
  vim.lsp.util.jump_to_location(command.arguments[1], client.offset_encoding, true)
end

vim.lsp.commands['rust-analyzer.showReferences'] = function()
  vim.lsp.buf.implementation()
end

local mappings = {
  { 'n', '<leader>rr', runnables, desc = 'runnables' },
  { 'n', '<leader>rl', execute_last_runnable, desc = 'execute last runnable' },
  { 'n', '<leader>rm', expand_macro_recursively, desc = 'expand macro recursively' },
  { 'n', '<leader>rd', open_external_docs, desc = 'open external docs' },
}

local commands = {
  { 'RustRunnables', runnables, desc = 'runnables' },
  { 'RustLastRun', execute_last_runnable, desc = 'execute last runnable' },
  { 'RustExpandMacro', expand_macro_recursively, desc = 'expand macro recursively' },
  { 'RustOpenExternalDocs', open_external_docs, desc = 'open external docs' },
  { 'RustRunFlycheck', run_flycheck, desc = 'run flycheck' },
  { 'RustCancelFlycheck', cancel_flycheck, desc = 'cancel flycheck' },
  { 'RustClearFlycheck', clear_flycheck, desc = 'clear flycheck' },
  { 'RustViewCrateGraph', view_crate_graph, desc = 'view crate graph' },
  { 'RustViewCrateGraphFull', view_crate_graph_full, desc = 'view full crate graph' },
}

-- Setup the buffer local mappings and commands for the `rust-analyzer` extension features.
---@param bufnr number
function M.on_attach(bufnr)
  vim.iter(mappings):each(function(m)
    vim.keymap.set(m[1], m[2], m[3], {
      buffer = bufnr,
      desc = ('rust-analyzer: %s'):format(m.desc),
    })
  end)

  vim.iter(commands):each(function(c)
    vim.api.nvim_buf_create_user_command(bufnr, c[1], c[2], {
      desc = ('rust-analyzer: %s'):format(c.desc),
    })
  end)
end

return M
