local timeout = 2000
local clear_message_timer

-- Format the LSP message data to be displayed in the statusline.
---@param data table
---@return string
local function format_data(data)
  local message
  if data.progress then
    message = data.title
    if data.message then
      message = message .. ' ' .. data.message
    end
    if data.percentage then
      message = message .. (' (%.0f%%)'):format(data.percentage)
    end
  else
    message = data.content
  end
  if message then
    message = '[' .. data.name .. '] ' .. message
  end
  return message
end

local function on_progress_update()
  local messages = vim.lsp.util.get_progress_messages()
  for _, data in ipairs(messages) do
    vim.api.nvim_echo({ { format_data(data), 'Grey' } }, false, {})
    if data.done then
      if clear_message_timer then
        clear_message_timer:stop()
      end
      clear_message_timer = vim.defer_fn(function()
        if vim.api.nvim_get_mode().mode == 'n' then
          vim.api.nvim_echo({}, false, {})
        end
        clear_message_timer = nil
      end, timeout)
    end
  end
end

vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('dm__lsp_progress', { clear = true }),
  pattern = 'LspProgressUpdate',
  callback = on_progress_update,
})
