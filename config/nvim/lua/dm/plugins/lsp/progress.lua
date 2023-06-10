-- Clear the cmdline.
local function clear_cmdline()
  if vim.api.nvim_get_mode().mode == 'n' then
    vim.api.nvim_echo({}, false, {})
  end
end

-- Format the LSP message data to be displayed.
---@param data table
---@param client_name string
---@return string
local function format_message(data, client_name)
  local message = data.title
  if data.message then
    message = message .. ' ' .. data.message
  end
  if data.percentage then
    message = message .. (' (%d%%)'):format(data.percentage)
  end
  if message then
    message = '[' .. client_name .. '] ' .. message
  end
  return message
end

do
  local timeout = 3000
  local clear_message_timer

  local group =
    vim.api.nvim_create_augroup('dm__lsp_progress', { clear = true })

  vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      vim.api.nvim_echo({
        { format_message(event.data.result.value, client.name), 'Grey' },
      }, false, {})
    end,
    desc = 'LSP: echo progress message',
  })

  vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    pattern = 'end',
    callback = function()
      if clear_message_timer then
        clear_message_timer:stop()
      end
      clear_message_timer = vim.defer_fn(clear_cmdline, timeout)
    end,
    desc = 'LSP: clear cmdline after progress ends',
  })
end
