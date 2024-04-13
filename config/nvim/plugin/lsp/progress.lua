local ELLIPSIS = '...'

-- Clear the cmdline.
local function clear_cmdline()
  if vim.api.nvim_get_mode().mode == 'n' then
    vim.api.nvim_echo({}, false, {})
  end
end

-- Truncate the message to fit the command line. This is to avoid the "Press Enter" prompt
-- which blocks the UI
---@param message string
---@return string
local function truncate_message(message)
  -- It seems like Neovim requires these many characters on the end of the command bar to display
  -- certain things like the number of lines in visual mode or keymaps pressed.
  local limit = vim.o.columns - 12
  if string.len(message) > limit then
    return string.sub(message, 1, limit - string.len(ELLIPSIS)) .. ELLIPSIS
  end
  return message
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
  return truncate_message(message)
end

do
  local timeout = 3000
  local clear_message_timer

  local group = vim.api.nvim_create_augroup('dm__lsp_progress', { clear = true })

  vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client == nil then
        return
      end
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
