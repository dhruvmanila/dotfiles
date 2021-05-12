local row, col = unpack(vim.api.nvim_win_get_cursor(0))

local win_opts = {
  relative = "cursor", -- 'editor', 'win', 'cursor'
  anchor = "NW", -- corner of the float to place at (row, col)
  width = 30,
  height = 10,
  row = 1,
  col = 1,
  style = "minimal",
  -- border = "single", -- 'single', 'double', 'shadow', 'none'
  border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
}

-- Create a new unlisted scratch buffer
local bufnr = vim.api.nvim_create_buf(false, true)

-- Open a floating window in the current buffer and make it the current window
local winnr = vim.api.nvim_open_win(bufnr, false, win_opts)

vim.api.nvim_command(
  "autocmd CursorMoved * ++once lua vim.api.nvim_win_close("
    .. winnr
    .. ", true)"
)

-- local popup = require("popup")

local lines = {
  "This is a test",
  "what for if I may ask?",
  "I don't know, we shall find out",
  "Hmm, lets see.",
}

-- local winnr, border = popup.create(lines, {
--   relative = "cursor",
--   title = "Testing ",
--   enter = true,
--   border = true,
-- })

-- P(winnr)
-- P(border)
