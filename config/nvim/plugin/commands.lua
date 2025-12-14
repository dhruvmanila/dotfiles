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

-- LspClient {{{1

do
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
        end, vim.lsp.get_clients())
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
    local _, info = next(vim.lsp.get_clients {
      name = opts.fargs[1],
    })
    if opts.fargs[2] ~= nil then
      info = info[opts.fargs[2]]
    end
    vim.print(info)
  end, {
    nargs = '+',
    complete = client_completion,
    desc = 'Print information about the LSP client',
  })
end

-- LspLog {{{1

do
  local logdir = vim.fn.stdpath 'log'
  ---@cast logdir string

  nvim_create_user_command('LspLog', function(opts)
    local current = vim.api.nvim_get_current_tabpage()
    if opts.args ~= '' then
      vim.cmd.tabnew(vim.fs.joinpath(logdir, ('lsp.%s.log'):format(opts.args)))
    else
      vim.cmd.tabnew(vim.lsp.log.get_filename())
    end
    vim.keymap.set('n', 'q', function()
      vim.cmd.tabclose()
      if vim.api.nvim_tabpage_is_valid(current) then
        vim.api.nvim_set_current_tabpage(current)
      end
    end, { buffer = 0, nowait = true })
  end, {
    nargs = '?',
    desc = 'Opens the LSP client log file, or Nvim LSP log file if no client name is provided',
    complete = function(arglead)
      local client_names = {}
      for name, type in vim.fs.dir(logdir) do
        if type == 'file' then
          local match = name:match '^lsp%.([^%.]+)%.log$'
          if match then
            table.insert(client_names, match)
          end
        end
      end

      if arglead == '' then
        return client_names
      else
        arglead = '.*' .. arglead .. '.*'
        return vim.tbl_filter(function(client_name)
          return client_name:match(arglead)
        end, client_names)
      end
    end,
  })
end

-- LspSetLogLevel {{{1

nvim_create_user_command('LspSetLogLevel', function(opts)
  vim.lsp.log.set_level(opts.args)
end, {
  nargs = 1,
  complete = function(arglead)
    return vim.tbl_filter(function(level)
      return type(level) == 'string' and level:match(arglead)
    end, vim.tbl_keys(vim.lsp.log_levels))
  end,
  desc = 'Set the log level for the LSP',
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
