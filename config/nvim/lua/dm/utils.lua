local M = {}
local fn = vim.fn
local api = vim.api

-- Creates a table with sensible default options for a floating window. The
-- table can be passed to |nvim_open_win()|.
--
-- This is a simplified version of the original function
-- |vim.lsp.util.make_floating_popup_options()|.
--
---@param width number window width (in character cells)
---@param height number window height (in character cells)
---@param border? string[]
---@return table #opts table to be passed to `vim.api.nvim_open_win`
function M.make_floating_popup_options(width, height, border)
  local anchor = ""
  local row, col

  --                                 ┌ remove the current line from the count
  --                                 │
  local lines_above = fn.winline() - 1
  local lines_below = vim.o.lines - lines_above

  -- Explanation for `row`: {{{
  --
  -- Number of rows to offset in the x direction, positive means going down and
  -- negative means going up. The original position without any offset (0, 0)
  -- will give something like this:
  --
  --          (anchor = "N")                    (anchor = "S")
  --
  --     cursor is here ->█───────┐                        ┌───────┐
  --                      │       │                        │       │
  --                      │       │       cursor is here ->█       │
  --                      └───────┘                        └───────┘
  --
  -- So, to shift the floating window to just above/below the cursor, the `row`
  -- value should be 1 for the North direction and -2 or 0 for the South direction.
  -- The -2 or 0 is for when the border is given or not respectively.
  -- }}}
  if lines_above < lines_below then
    anchor = anchor .. "N"
    height = math.min(lines_below, height)
    row = 1
  else
    anchor = anchor .. "S"
    height = math.min(lines_above, height)
    row = border and -2 or 0
  end

  -- Difference between the original version: {{{
  --
  -- For deciding between the East and West anchor, the original version only
  -- takes the number of columns from the *current* window. We need to actually
  -- take the number of columns from the left edge of the *editor* which would
  -- be in the case of splits.
  -- }}}
  local col_left = api.nvim_win_get_position(0)[2] + fn.wincol()
  if col_left + width <= vim.o.columns then
    anchor = anchor .. "W"
    col = 0
  else
    anchor = anchor .. "E"
    col = 1
  end

  return {
    anchor = anchor,
    border = border,
    col = col,
    height = height,
    relative = "cursor",
    row = row,
    style = "minimal",
    width = width,
  }
end

return M
