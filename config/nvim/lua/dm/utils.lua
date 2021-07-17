local M = {}
local fn = vim.fn
local api = vim.api
local cmd = api.nvim_command

-- TODO: eventually move to using `nvim_set_hl` however for the time being
-- that expects colors to be specified as rgb not hex.
---@param name string
---@param opts table<string, boolean|string>
function M.highlight(name, opts)
  local force = opts.force or false
  if name and vim.tbl_count(opts) > 0 then
    if opts.link and opts.link ~= "" then
      cmd(
        "highlight"
          .. (force and "!" or "")
          .. " link "
          .. name
          .. " "
          .. opts.link
      )
    else
      local hi_cmd = { "highlight", name }
      if opts.guifg and opts.guifg ~= "" then
        table.insert(hi_cmd, "guifg=" .. opts.guifg)
      end
      if opts.guibg and opts.guibg ~= "" then
        table.insert(hi_cmd, "guibg=" .. opts.guibg)
      end
      if opts.gui and opts.gui ~= "" then
        table.insert(hi_cmd, "gui=" .. opts.gui)
      end
      if opts.guisp and opts.guisp ~= "" then
        table.insert(hi_cmd, "guisp=" .. opts.guisp)
      end
      if opts.cterm and opts.cterm ~= "" then
        table.insert(hi_cmd, "cterm=" .. opts.cterm)
      end
      if opts.blend then
        table.insert(hi_cmd, "blend=" .. opts.blend)
      end
      cmd(table.concat(hi_cmd, " "))
    end
  end
end

-- Fixed column cursor movements with line limits. This will skip any blank
-- lines in between. This should only be used in autocmds with CursorHold event.
-- `opts` table expects the followings keys to be present:
--   - firstline (number) Upper row limit
--   - lastline (number) Lower row limit
--   - fixed_column (number) Column to fix the cursor at
--   - newline (number) Current cursor line
-- Internal:
--   - oldline (number) Previous cursor line
---@param opts table<string, number>
---@return nil
function M.fixed_column_movement(opts)
  local oldline = opts.newline
  local newline = api.nvim_win_get_cursor(0)[1]

  -- Direction: up (-1) or down (+1) (no horizontal movements are registered)
  local movement = 2 * (newline > oldline and 1 or 0) - 1

  -- Skip blank lines between entries
  if api.nvim_buf_get_lines(0, newline - 1, newline, false)[1] == "" then
    newline = newline + movement
  end

  -- Don't go beyond first or last entry
  newline = math.max(opts.firstline, math.min(opts.lastline, newline))

  -- Update the numbers and the cursor position
  opts.oldline = oldline
  opts.newline = newline
  api.nvim_win_set_cursor(0, { newline, opts.fixed_column })
end

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

-- Helper function to create a floating window in which the output of
-- `:StartupTime` will be displayed.
function M.startuptime()
  local width = vim.o.columns - 20
  local height = vim.o.lines - 9
  local bufnr = api.nvim_create_buf(false, true)

  local winnr = api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = dm.border[vim.g.border_style],
  })

  cmd "StartupTime"
  vim.bo.bufhidden = "wipe"
  vim.wo.cursorline = true
  local quit_fn = string.format(
    "<Cmd>lua vim.api.nvim_win_close(%d, true)<CR>",
    winnr
  )
  local opts = { noremap = true, nowait = true, silent = true }
  api.nvim_buf_set_keymap(0, "n", "q", quit_fn, opts)
end

return M
