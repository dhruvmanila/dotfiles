local api = vim.api
local fn = vim.fn

do
  -- Trim trailing whitespace for the current buffer, restoring the
  -- cursor position.
  local function trim_trailing_whitespace()
    local pos = api.nvim_win_get_cursor(0)
    vim.cmd [[keeppatterns keepjumps %s/\s\+$//e]]
    api.nvim_win_set_cursor(0, pos)
  end

  dm.command {
    "TrimTrailingWhitespace",
    trim_trailing_whitespace,
    attr = { "-bar" },
  }
end

do
  -- Trim blank lines at the end of the current buffer, restoring the
  -- cursor position.
  local function trim_trailing_lines()
    local pos = api.nvim_win_get_cursor(0)
    local last_line = api.nvim_buf_line_count(0)
    local last_non_blank_line = fn.prevnonblank(last_line)

    if last_non_blank_line > 0 and last_line ~= last_non_blank_line then
      api.nvim_buf_set_lines(0, last_non_blank_line, last_line, false, {})
    end

    api.nvim_win_set_cursor(0, pos)
  end

  dm.command { "TrimTrailingLines", trim_trailing_lines, attr = { "-bar" } }
end

dm.command { "Term", "new | wincmd J | resize -5 | term" }
dm.command { "Vterm", "vnew | wincmd L | term" }
dm.command { "Tterm", "tabnew | term" }
