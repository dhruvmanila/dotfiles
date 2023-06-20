local M = {}

-- Helper function to ask the user for arguments.
---@return string[]
function M.ask_for_arguments()
  local args = vim.fn.input 'Arguments: '
  return vim.split(args, ' +', { trimempty = true })
end

return M
