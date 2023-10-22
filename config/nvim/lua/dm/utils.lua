local M = {}

-- Return `true` if the current buffer is empty, `false` otherwise.
---@param bufnr? integer
---@return boolean
function M.buf_is_empty(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_line_count(bufnr) == 1
    and vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)[1] == ''
end

return M
