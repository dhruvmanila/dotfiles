local M = {}

-- Return `true` if the current buffer is empty, `false` otherwise.
---@param bufnr? integer
---@return boolean
function M.buf_is_empty(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_line_count(bufnr) == 1
    and vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)[1] == ''
end

-- Create and return a timer for the given callback to be invoked every `interval` ms.
--
-- It is the caller's responsibility to stop the timer when it is no longer needed
-- with `timer:stop()`.
--
-- The callback is invoked immediately for the first time and then every `interval` ms.
---@param interval number in milliseconds
---@param callback function
---@return uv_timer_t #timer handle (uv_timer_t)
function M.set_interval_callback(interval, callback)
  local timer = vim.uv.new_timer()
  timer:start(0, interval, function()
    callback()
  end)
  return timer
end

-- Returns the current buffer's LSP client for the given language server name.
-- Raises an error if no client is found.
---@param name string
---@return vim.lsp.Client
function M.get_client(name)
  return assert(
    vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), name = name })[1],
    ('No %s client found for the current buffer'):format(name)
  )
end

-- Helper function to ask the user for arguments.
---@return string[]
function M.ask_for_arguments()
  local args = vim.fn.input 'Arguments: '
  return vim.split(args, ' +', { trimempty = true })
end

return M
