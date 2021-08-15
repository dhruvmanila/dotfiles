local M = {}
local fn = vim.fn
local api = vim.api

-- Simplified version of `vim.lsp.util.make_floating_popup_options`
-- This will consider the number of columns from the left end of neovim instead
-- of the current window.
---@param width number width of the popup window
---@param height number height of the popup window
---@param border? string[]
---@return table @opts table to be passed to `vim.api.nvim_open_win`
function M.make_floating_popup_options(width, height, border)
  local anchor = ""
  local row, col

  local lines_above = fn.winline() - 1
  local lines_below = api.nvim_get_option "lines" - lines_above

  if lines_above < lines_below then
    anchor = anchor .. "N"
    height = math.min(lines_below, height)
    row = 1
  else
    anchor = anchor .. "S"
    height = math.min(lines_above, height)
    row = border and -2 or 0
  end

  local col_left = api.nvim_win_get_position(0)[2] + fn.wincol() + width
  if col_left <= api.nvim_get_option "columns" then
    anchor = anchor .. "W"
    col = 0
  else
    anchor = anchor .. "E"
    col = 1
  end

  return {
    relative = "cursor",
    anchor = anchor,
    height = height,
    width = width,
    row = row,
    col = col,
    style = "minimal",
    border = border,
  }
end

return M
