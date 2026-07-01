-- This module is used to setup anything when using Neovim as a scrollback for the Kitty terminal.
--
-- See: https://sw.kovidgoyal.net/kitty/conf/#scrollback

local INPUT_LINE_NUMBER = tonumber(vim.env.INPUT_LINE_NUMBER) or 0
local CURSOR_LINE = tonumber(vim.env.CURSOR_LINE) or 1
local CURSOR_COLUMN = tonumber(vim.env.CURSOR_COLUMN) or 1

vim.w.kitty_scrollback = {
  input_line_number = INPUT_LINE_NUMBER,
  cursor_line = CURSOR_LINE,
  cursor_column = CURSOR_COLUMN,
}

-- Override options.
vim.o.cmdheight = 0
vim.o.laststatus = 0
vim.o.list = false
vim.o.number = false
vim.o.relativenumber = false
vim.o.signcolumn = 'no'
vim.o.scrolloff = 0

vim.keymap.set('n', 'q', '<Cmd>qa<CR>', { noremap = true })

do
  -- Keep these colors in sync with Kitty's light/dark theme palettes:
  -- config/kitty/dark-theme.auto.conf
  -- config/kitty/light-theme.auto.conf
  local terminal_colors = vim.o.background == 'dark'
      and {
        '#3c3836',
        '#cc241d',
        '#98971a',
        '#d79921',
        '#458588',
        '#b16286',
        '#689d6a',
        '#a89984',
        '#928374',
        '#fb4934',
        '#b8bb26',
        '#fabd2f',
        '#83a598',
        '#d3869b',
        '#8ec07c',
        '#fbf1c7',
      }
    or {
      '#ebdbb2',
      '#cc241d',
      '#98971a',
      '#d79921',
      '#458588',
      '#b16286',
      '#689d6a',
      '#7c6f64',
      '#928374',
      '#9d0006',
      '#79740e',
      '#b57614',
      '#076678',
      '#8f3f71',
      '#427b58',
      '#282828',
    }

  for index, color in ipairs(terminal_colors) do
    vim.g['terminal_color_' .. (index - 1)] = color
  end
end

local function position_cursor()
  local timer = assert(vim.uv.new_timer())
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
        math.max(1, INPUT_LINE_NUMBER + CURSOR_LINE - 1),
        math.max(0, CURSOR_COLUMN - 1),
      })
      if ok then
        -- Required for Kitty's show_scrollback action to keep the window view
        -- exactly as it was before opening the scrollback pager; otherwise it
        -- scrolls up by one line.
        vim.fn.winrestview {
          topline = math.max(1, INPUT_LINE_NUMBER),
        }
        stop_timer()
      end
    end)
  )

  vim.defer_fn(stop_timer, 2000)
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('dm_kitty_scrollback', { clear = true }),
  once = true,
  callback = function()
    vim.api.nvim_open_term(0, {})
    vim.bo.modified = false

    vim.defer_fn(position_cursor, 10)
  end,
})
