local M = {}

-- Returns the current buffer's client for the given language server name.
-- Raises an error if no client is found.
---@param name string
---@return lsp.Client
function M.get_client(name)
  return assert(
    vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), name = name })[1],
    ('No %s client found for the current buffer'):format(name)
  )
end

return M
