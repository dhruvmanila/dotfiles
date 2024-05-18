-- Client side extensions for `rust-analyzer` language server.
local M = {}

local utils = require 'dm.utils'

local logger = dm.log.get_logger 'lsp.rust_analyzer'

-- Notification title.
local TITLE = 'rust-analyzer'

local cache = {
  -- Bufnr for the latest executed command.
  ---@type number?
  run_single_bufnr = nil,

  -- Bufnr for the latest expanded macro output.
  ---@type number?
  expand_macro_bufnr = nil,

  -- Bufnr for the latest syntax tree output.
  ---@type number?
  syntax_tree_bufnr = nil,

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

-- Format the expanded macro output.
---@param macro ExpandedMacro
---@return string[]
local function format_expanded_macro(macro)
  local header = ('// Rescursive expansion of `%s` macro:'):format(macro.name)
  return vim
    .iter({
      header,
      '// ' .. string.rep('=', #header - 3),
      '',
      vim.split(macro.expansion, '\n', { plain = true, trimempty = true }),
    })
    :flatten()
    :totable()
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
  local terminal_winnr = vim.api.nvim_open_win(cache.run_single_bufnr, true, {
    split = 'below',
    height = math.ceil(vim.o.lines * 0.35),
  })

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
  local args = vim
    .iter({
      runnable.args.cargoArgs,
      runnable.args.cargoExtraArgs,
      '--',
      runnable.args.executableArgs,
    })
    :flatten()
    :totable()
  execute_command('cargo', args, runnable.args.workspaceRoot)
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
    vim.iter({ runnable.args.cargoArgs, '--message-format=json' }):flatten():totable()
  if cargo_args[1] == 'run' then
    cargo_args[1] = 'build'
  elseif cargo_args[1] == 'test' then
    if not vim.list_contains(cargo_args, '--no-run') then
      table.insert(cargo_args, '--no-run')
    end
  end

  dm.notify(TITLE, 'Compiling a debug build for debugging. This might take some time...', nil, {
    timeout = false,
  })

  vim.system(
    vim.iter({ 'cargo', cargo_args }):flatten():totable(),
    { cwd = runnable.args.workspaceRoot },
    ---@param result vim.SystemCompleted
    vim.schedule_wrap(function(result)
      require('notify').dismiss()
      if result.code > 0 then
        dm.notify(
          TITLE,
          'An error occurred while compiling:\n' .. result.stderr,
          vim.log.levels.ERROR
        )
        return
      end
      dm.notify(TITLE, 'Compilation successful')

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
        dm.notify(TITLE, 'No compilation artifacts', vim.log.levels.ERROR)
        return
      elseif #executables > 1 then
        dm.notify(TITLE, 'Multiple compilation artifacts are not supported', vim.log.levels.ERROR)
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
        cwd = vim.fs.root(0, 'Cargo.toml') or runnable.args.workspaceRoot,
        console = 'internalConsole',
        stopOnEntry = false,
      }
      logger.info('Launching DAP with config: %s', dap_config)
      require('dap').run(dap_config)
    end)
  )
end

-- Show a list of runnables and execute the selected one. This uses the `vim.ui.select` function
-- to provide a list of runnables for the user to choose from.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#runnables
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
        dm.notify(TITLE, tostring(err), vim.log.levels.ERROR)
        return
      end

      local notification = dm.notify(TITLE, 'Processing crate graph. This may take a while...')

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
              TITLE,
              'Failed to process crate graph:\n\n' .. result.stderr,
              vim.log.levels.ERROR,
              { replace = notification }
            )
            return
          end

          ---@diagnostic disable-next-line: param-type-mismatch
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
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#view-crate-graph
local function view_crate_graph_full()
  view_crate_graph_impl(true)
end

-- View the crate graph.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#view-crate-graph
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
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#expand-macro
local function expand_macro_recursively()
  utils
    .get_client('rust_analyzer')
    .request('rust-analyzer/expandMacro', vim.lsp.util.make_position_params(), function(_, expanded)
      ---@cast expanded ExpandedMacro
      if expanded == nil then
        dm.notify(TITLE, 'No macro under cursor', vim.log.levels.WARN)
        return
      end

      delete_bufnr(cache.expand_macro_bufnr)
      cache.expand_macro_bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_open_win(cache.expand_macro_bufnr, true, {
        split = 'below',
        height = math.ceil(vim.o.lines * 0.3),
      })

      -- Once the buffer is set for the current window, we can use 0 to refer to it.
      vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<Cmd>q<CR>', { noremap = true })
      vim.bo[cache.expand_macro_bufnr].filetype = 'rust'
      vim.api.nvim_buf_set_lines(0, 0, 0, false, format_expanded_macro(expanded))

      -- Move cursor to the start of the macro expansion.
      vim.api.nvim_win_set_cursor(0, { 4, 0 })
    end)
end

-- Open the documentation for the symbol under the cursor.
--
-- This assumes that the `localDocs` experimental feature is enabled.
--
-- See:
-- * https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#open-external-documentation
-- * https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#local-documentation
local function open_external_docs()
  utils
    .get_client('rust_analyzer')
    .request('experimental/externalDocs', vim.lsp.util.make_position_params(), function(_, result)
      ---@cast result ExternalDocsResponse
      local url = result['local'] or result.web
      if url == nil then
        dm.notify(TITLE, 'No documentation found', vim.log.levels.WARN)
        return
      end
      vim.ui.open(url)
    end)
end

-- Show the syntax tree for the current buffer.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#syntax-tree
local function syntax_tree()
  utils
    .get_client('rust_analyzer')
    .request('rust-analyzer/syntaxTree', vim.lsp.util.make_range_params(), function(_, result)
      delete_bufnr(cache.syntax_tree_bufnr)
      cache.syntax_tree_bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_open_win(cache.syntax_tree_bufnr, true, {
        vertical = true,
        split = 'right',
        width = math.ceil(vim.o.columns * 0.4),
      })

      -- Once the buffer is set for the current window, we can use 0 to refer to it.
      vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<Cmd>q<CR>', { noremap = true })
      vim.bo[cache.syntax_tree_bufnr].filetype = 'rust'
      local lines = vim.split(result, '\n', { plain = true, trimempty = true })
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

      -- Move the cursor to the start of the syntax tree.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end)
end

-- Move the cursor to the matching brace for the one at the current position.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#matching-brace
local function matching_brace()
  local params = vim.lsp.util.make_position_params()
  utils.get_client('rust_analyzer').request('experimental/matchingBrace', {
    textDocument = params.textDocument,
    positions = { params.position },
  }, function(_, positions, ctx)
    ---@cast positions lsp.Position[]
    if vim.tbl_isempty(positions) then
      logger.warn('%s: empty response', ctx.method)
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client == nil then
      return
    end
    local position = positions[1]
    if #positions > 1 then
      logger.warn('%s: multiple positions: %s (using the first position)', ctx.method, positions)
    end
    local offset =
      vim.lsp.util._get_line_byte_from_position(ctx.bufnr, position, client.offset_encoding)
    local winid = vim.fn.bufwinid(ctx.bufnr)
    -- LSP's line is 0-indexed while Neovim's line is 1-indexed.
    vim.api.nvim_win_set_cursor(winid, { position.line + 1, offset })
  end)
end

-- Open current project's Cargo.toml file.
--
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/docs/dev/lsp-extensions.md#open-cargotoml
local function open_cargo_toml()
  utils.get_client('rust_analyzer').request(
    'experimental/openCargoToml',
    { textDocument = vim.lsp.util.make_text_document_params() },
    function(_, location, ctx)
      ---@cast location lsp.Location?
      if location == nil then
        return
      end
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client == nil then
        return
      end
      vim.lsp.util.jump_to_location(location, client.offset_encoding, true)
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

-- List of mappings to be defined on server attach.
---@type { [1]: string, [2]: string, [3]: function, desc: string }[]
local mappings = {
  { 'n', '<leader>rr', runnables, desc = 'runnables' },
  { 'n', '<leader>rl', execute_last_runnable, desc = 'execute last runnable' },
  { 'n', '<leader>rm', expand_macro_recursively, desc = 'expand macro recursively' },
  { 'n', '<leader>rd', open_external_docs, desc = 'open external docs' },
  { 'n', '<leader>rt', open_cargo_toml, desc = 'open Cargo.toml' },
  -- A language server can understand this much better because it uses the parser instead of regex.
  { 'n', '%', matching_brace, desc = 'matching brace' },
}

-- List of user commands to be defined on server attach.
---@type { [1]: string, [2]: function, desc: string }[]
local commands = {
  { 'RustRunnables', runnables, desc = 'runnables' },
  { 'RustLastRun', execute_last_runnable, desc = 'execute last runnable' },
  { 'RustExpandMacro', expand_macro_recursively, desc = 'expand macro recursively' },
  { 'RustOpenExternalDocs', open_external_docs, desc = 'open external docs' },
  { 'RustOpenCargoToml', open_cargo_toml, desc = 'open Cargo.toml' },
  { 'RustRunFlycheck', run_flycheck, desc = 'run flycheck' },
  { 'RustCancelFlycheck', cancel_flycheck, desc = 'cancel flycheck' },
  { 'RustClearFlycheck', clear_flycheck, desc = 'clear flycheck' },
  { 'RustViewCrateGraph', view_crate_graph, desc = 'view crate graph' },
  { 'RustViewCrateGraphFull', view_crate_graph_full, desc = 'view full crate graph' },
  { 'RustSyntaxTree', syntax_tree, desc = 'syntax tree' },
  { 'RustMatchingBrace', matching_brace, desc = 'matching brace' },
}

-- Setup the buffer local mappings and commands for the `rust-analyzer` extension features.
---@param _ vim.lsp.Client
---@param bufnr number
function M.on_attach(_, bufnr)
  for _, m in ipairs(mappings) do
    vim.keymap.set(m[1], m[2], m[3], { buffer = bufnr, desc = 'rust-analyzer: ' .. m.desc })
  end

  for _, c in ipairs(commands) do
    vim.api.nvim_buf_create_user_command(bufnr, c[1], c[2], { desc = 'rust-analyzer: ' .. c.desc })
  end
end

return M
