local fn = vim.fn
local api = vim.api

-- :TrimTrailingWhitespace - Trim trailing whitespace for the current buffer,
-- restoring the cursor position.
--
-- This command can be followed by a "|" and another command.
dm.command { "TrimTrailingWhitespace", function()
  local pos = api.nvim_win_get_cursor(0)
  vim.cmd [[keeppatterns keepjumps %s/\s\+$//e]]
  api.nvim_win_set_cursor(0, pos)
end, attr = {
  "-bar",
} }

-- :TrimTrailingLines - Trim blank lines at the end of the current buffer,
-- restoring the cursor position.
--
-- This command can be followed by a "|" and another command.
dm.command { "TrimTrailingLines", function()
  local pos = api.nvim_win_get_cursor(0)
  local last_line = api.nvim_buf_line_count(0)
  local last_non_blank_line = fn.prevnonblank(last_line)

  if last_non_blank_line > 0 and last_line ~= last_non_blank_line then
    api.nvim_buf_set_lines(0, last_non_blank_line, last_line, false, {})
  end

  api.nvim_win_set_cursor(0, pos)
end, attr = {
  "-bar",
} }

-- :Term - Open the terminal on the bottom occupying full width of the editor.
dm.command { "Term", "new | wincmd J | resize -5 | term" }

-- :Vterm - Open the terminal on the right hand side occupying full height of
-- the editor.
dm.command { "Vterm", "vnew | wincmd L | term" }

-- :Tterm - Open the terminal in a new tab.
dm.command { "Tterm", "tabnew | term" }

-- :BufOnly - Delete all the buffers except the current buffer while ignoring
-- any terminal buffers.
dm.command { "BufOnly", function()
  local deleted, modified = 0, 0
  local curr_buf = api.nvim_get_current_buf()
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted then
      if vim.bo[bufnr].modified then
        modified = modified + 1
      elseif bufnr ~= curr_buf and vim.bo[bufnr].buftype ~= "terminal" then
        api.nvim_buf_delete(bufnr, {})
        deleted = deleted + 1
      end
    end
  end
  if deleted > 0 or modified > 0 then
    vim.notify {
      "BufOnly",
      "",
      deleted .. " deleted buffer(s)",
      modified .. " modified buffer(s)",
    }
  end
end }
