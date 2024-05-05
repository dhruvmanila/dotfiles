-- This module is used to setup anything when using Neovim as a scrollback for the Kitty terminal.
--
-- See: https://sw.kovidgoyal.net/kitty/conf/#scrollback

local INPUT_LINE_NUMBER = tonumber(vim.env.INPUT_LINE_NUMBER)
local CURSOR_LINE = tonumber(vim.env.CURSOR_LINE)
local CURSOR_COLUMN = tonumber(vim.env.CURSOR_COLUMN)

vim.w.kitty_scrollback = {
  input_line_number = INPUT_LINE_NUMBER,
  cursor_line = CURSOR_LINE,
  cursor_column = CURSOR_COLUMN,
}

-- Override options.
vim.o.signcolumn = 'no'
vim.o.scrolloff = 0

vim.keymap.set('n', 'q', '<Cmd>qa<CR>', { noremap = true })

do
  local timer = vim.uv.new_timer()
  local timer_stopped = false

  local function stop_timer()
    if timer_stopped then
      return
    end
    timer:stop()
    timer:close()
    timer_stopped = true
  end

  timer:start(
    0,
    10,
    vim.schedule_wrap(function()
      local ok = pcall(vim.api.nvim_win_set_cursor, 0, {
        math.max(1, INPUT_LINE_NUMBER) + CURSOR_LINE,
        CURSOR_COLUMN,
      })
      if ok then
        stop_timer()
      end
    end)
  )

  vim.defer_fn(stop_timer, 2000)
end
