local fn = vim.fn
local api = vim.api
local nvim_create_user_command = api.nvim_create_user_command

-- BufOnly {{{1

nvim_create_user_command('BufOnly', function()
  local deleted, modified = 0, 0
  local curr_buf = api.nvim_get_current_buf()
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted then
      if vim.bo[bufnr].modified then
        modified = modified + 1
      elseif bufnr ~= curr_buf and vim.bo[bufnr].buftype ~= 'terminal' then
        api.nvim_buf_delete(bufnr, {})
        deleted = deleted + 1
      end
    end
  end
  if deleted > 0 then
    local info = { deleted .. ' deleted buffer(s)' }
    if modified > 0 then
      table.insert(info, modified .. ' modified buffer(s)')
    end
    dm.notify('BufOnly', info)
  end
end, {
  desc = 'Delete all but the current buffer (ignores terminal buffers)',
})

-- Dap {{{1

local dap_functions = {
  'clear_breakpoints',
  'close',
  'continue',
  'disconnect',
  'reverse_continue',
  'run_last',
  'run_to_cursor',
  'set_breakpoint',
  'set_exception_breakpoints',
  'step_back',
  'step_into',
  'step_out',
  'step_over',
  'terminate',
  'toggle_breakpoint',
}

nvim_create_user_command('Dap', function(opts)
  require('dap')[opts.args]()
end, {
  nargs = 1,
  complete = function(arglead)
    arglead = arglead and ('.*' .. arglead .. '.*')
    return vim.tbl_filter(function(fname)
      return fname:match(arglead)
    end, dap_functions)
  end,
  desc = 'Custom command for all nvim-dap functions',
})

-- LspClient {{{1

-- Available fields for LSP client object.
-- See: `:help vim.lsp.client`
local lsp_client_fields = {
  'attached_buffers',
  'commands',
  'config',
  'dynamic_capabilities',
  'handlers',
  'id',
  'initialized',
  'messages',
  'name',
  'offset_encoding',
  'progress',
  'requests',
  'rpc',
  'server_capabilities',
  'supports_method',
  'workspace_folders',
}

-- Completion function for LSP clients.
---@param arglead string
---@param line string
---@return string[] #Client info in the format of `client_id (client_name)`
local client_completion = function(arglead, line)
  if arglead ~= '' then
    arglead = '.*' .. arglead .. '.*'
  end

  -- `trimempty` shouldn't be used here to get the actual number of arguments
  -- passed to the command. It'll be an empty string for the argument position
  -- that is being completed or `arglead`.
  local args = vim.split(line, '%s+')
  local count = #args - 2

  if count == 0 then
    -- Autocomplete client name
    return vim.tbl_map(
      function(client)
        return client.name
      end,
      vim.tbl_filter(function(client)
        return client.name:match(arglead)
      end, vim.lsp.get_active_clients())
    )
  elseif count == 1 then
    -- Autocomplete client object fields
    return vim.tbl_filter(function(field)
      return field:match(arglead)
    end, lsp_client_fields)
  end

  -- No completion for other arguments
  return {}
end

nvim_create_user_command('LspClient', function(opts)
  local _, info = next(vim.lsp.get_active_clients {
    name = opts.fargs[1],
  })
  if opts.fargs[2] ~= nil then
    info = info[opts.fargs[2]]
  end
  vim.print(info)
end, {
  nargs = '+',
  complete = client_completion,
  desc = 'LspClient <client_name> [<client_field>]: Print information about the LSP client',
})

-- Term / Vterm / Tterm {{{1

nvim_create_user_command('Term', 'new | wincmd J | resize -5 | term', {
  desc = 'Open the terminal on the bottom occupying full width of the editor',
})

nvim_create_user_command('Vterm', 'vnew | wincmd L | term', {
  desc = 'Open the terminal on the right hand side occupying full height of the editor',
})

nvim_create_user_command('Tterm', 'tabnew | term', {
  desc = 'Open the terminal in a new tab',
})

-- TrimLines {{{1

nvim_create_user_command('TrimLines', function()
  local pos = api.nvim_win_get_cursor(0)
  local last_line = api.nvim_buf_line_count(0)
  local last_non_blank_line = fn.prevnonblank(last_line)

  if last_non_blank_line > 0 and last_line ~= last_non_blank_line then
    api.nvim_buf_set_lines(0, last_non_blank_line, last_line, false, {})
  end

  api.nvim_win_set_cursor(0, pos)
end, {
  bar = true,
  desc = 'Trim blank lines at the end of the current buffer, restoring the cursor position',
})

-- TrimWhitespace {{{1

-- Purpose: Trim trailing whitespace for the current buffer, restoring the
-- cursor position. This command can be followed by another command.
nvim_create_user_command('TrimWhitespace', function()
  local pos = api.nvim_win_get_cursor(0)
  vim.cmd [[keeppatterns keepjumps %s/\s\+$//e]]
  api.nvim_win_set_cursor(0, pos)
end, {
  bar = true,
  desc = 'Trim trailing whitespace for the current buffer, restoring the cursor position',
})
