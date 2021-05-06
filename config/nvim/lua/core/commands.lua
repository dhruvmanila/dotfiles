local api = vim.api
local cmd = api.nvim_command
local fn = vim.fn

local M = {}

-- Report the highlight groups active at the current point.
-- Ref: https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
function M.highlight_groups()
  local line, col = unpack(api.nvim_win_get_cursor(0))
  col = col + 1  -- zero indexed :(

  local hi = fn.synIDattr(fn.synID(line, col, true), 'name')
  local trans = fn.synIDattr(fn.synID(line, col, false), 'name')
  local lo = fn.synIDattr(fn.synIDtrans(fn.synID(line, col, true)), 'name')

  print(string.format('hi: %s  trans: %s  lo: %s', hi, trans, lo))
end

-- Trim trailing whitespace in the current file.
-- This will save the current view of the window and restore it back.
function M.trim_trailing_whitespace()
  local pos = api.nvim_win_get_cursor(0)
  cmd([[keeppatterns %s/\s\+$//e]])
  api.nvim_win_set_cursor(0, pos)
end

-- Trim blank lines at the end of the file.
-- This will save the current view of the window and restore it back.
function M.trim_trailing_lines()
  local pos = api.nvim_win_get_cursor(0)
  local last_line = api.nvim_buf_line_count(0)
  local last_non_blank_line = fn.prevnonblank(last_line)

  if last_non_blank_line > 0 and last_line ~= last_non_blank_line then
    api.nvim_buf_set_lines(0, last_non_blank_line, last_line, false, {})
  end

  api.nvim_win_set_cursor(0, pos)
end

local mod = ':lua require("core.commands").'
cmd('command! Hi ' .. mod .. 'highlight_groups()')
cmd('command! -bar TrimTrailingWhitespace ' .. mod .. 'trim_trailing_whitespace()')
cmd('command! -bar TrimTrailingLines ' .. mod .. 'trim_trailing_lines()')

return M
