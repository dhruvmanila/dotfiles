local timeout = 1000
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
      message = message .. (' (%.0f%%%%)'):format(data.percentage)
    end
  else
    message = data.content
  end
  return message
end

local function on_progress_update()
  local messages = vim.lsp.util.get_progress_messages()
  for _, data in ipairs(messages) do
    vim.g.lsp_progress_message = format_data(data)
  end
  if clear_message_timer then
    clear_message_timer:stop()
  end
  -- Reset the variable to clear the statusline.
  clear_message_timer = vim.defer_fn(function()
    vim.g.lsp_progress_message = nil
    clear_message_timer = nil
  end, timeout)
end

vim.api.nvim_create_autocmd('User', {
  group = 'dm__statusline',
  pattern = 'LspProgressUpdate',
  callback = on_progress_update,
})
