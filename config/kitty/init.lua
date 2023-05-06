-- Extract out the values sent by kitty.
local input_line_number = tonumber(vim.env.INPUT_LINE_NUMBER)
local cursor_line = tonumber(vim.env.CURSOR_LINE)
local cursor_column = tonumber(vim.env.CURSOR_COLUMN)

vim.opt.clipboard:append 'unnamedplus'
vim.opt.shell = 'bash'
vim.opt.showtabline = 0
vim.opt.signcolumn = 'no'

vim.keymap.set('n', 'q', '<Cmd>qa<CR>', { noremap = true })

do
  local group = vim.api.nvim_create_augroup('dm__kitty_scrollback', {
    clear = true,
  })

  vim.api.nvim_create_autocmd('TermEnter', {
    group = group,
    command = 'stopinsert',
  })
end

vim.defer_fn(function()
  vim.api.nvim_win_set_cursor(0, {
    math.max(1, input_line_number) + cursor_line,
    cursor_column,
  })
end, 30)
