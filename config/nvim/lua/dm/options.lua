local opt = vim.opt

-- When `'statusline'` is empty, Vim displays the current line address, and
-- column number, in the statusline. This region is called the “ruler bar“
-- (`:help ruler`).
--
-- Even though we should never see it, disable it explicitly.
opt.ruler = false

-- NOTE: If on, it can erase a message ouput by `:echo` or `:lua print`
opt.showmode = false

-- `:h provider-clipboard`
opt.clipboard:append 'unnamedplus'

opt.completeopt = {
  'menuone',
  'noinsert',
}

-- Maxmimum number of items to show in the popup menu (|inc-completion-menu|)
opt.pumheight = 20

-- Hide the conceal characters unless the cursor is on that line.
opt.conceallevel = 2

opt.diffopt:append {
  -- Use the indent heuristic for the internal diff library, because it gives
  -- more readable diffs.
  -- See: https://vimways.org/2018/the-power-of-diff/
  'indent-heuristic',

  -- Start diff mode with vertical splits (unless explicitly specified otherwise)
  'vertical',
}

-- Might fix various issues when editing a line containing some emojis.
-- See: https://www.youtube.com/watch?v=F91VWOelFNE&t=174s
opt.emoji = false

opt.exrc = true

opt.fillchars = {
  -- Don't print '~' at the start of the lines after the last buffer line
  eob = ' ',

  -- Fill 'foldtext' with simple dots instead of hyphens
  fold = '·',

  -- Replace the ugly default icons '+' and '-' with prettier utf8 characters.
  -- These are only visible in the `foldcolumn`
  foldclose = '▸',
  foldopen = '▾',
  foldsep = '│',

  -- Use thick lines for window separators.
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- See: `:h fo-table`
opt.formatoptions = {
  c = true,
  q = true,
  r = true,
  j = true,
  n = true, -- using 'formatlistpat'
}

-- Used for the "n" flag in 'formatoptions'
--                           ┌ recognize numbered lists (default)
--                           ├─────────────┐
opt.formatlistpat = [[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\)\s*]]
--                                            ├───┘
--                                            └ recognize unordered lists

-- Treesitter based folding (requires 'foldmethod=expr')
-- opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Default fold method is marker for now.
opt.foldmethod = 'marker'

-- Close a fold even if it doesn't contain any line.
opt.foldminlines = 0

-- copy the structure of existing lines indent
opt.copyindent = true

-- Use spaces intead of TAB
opt.expandtab = true

-- What's the effect of 'shiftround'? {{{
--
-- When you press:
--
--    - `{count}>>`
--    - `{count}<<`
--    - `>{motion}`
--    - `<{motion}`
--
-- ... on indented lines, if `'shiftround'` is enabled, the new level of
-- indentation will be a multiple of `&shiftwidth`.
-- }}}
opt.shiftround = true

-- What's the effect of 'shiftwidth'? {{{
--
-- It controls the number of spaces added/removed when you press:
--
--    - `{count}>>`
--    - `{count}<<`
--    - `>{motion}`
--    - `<{motion}`
-- }}}
opt.shiftwidth = 2

-- Use 'shiftwidth' for `TAB`/`BS` {{{
--
-- When we press `Tab` or `BS` in other locations (i.e. after first
-- non-whitespace), we don't want 'softtabstop' to determine how many spaces are
-- added/removed (nor 'tabstop', hence why we don't set 'softtabstop' to zero).
-- }}}
opt.softtabstop = -1

-- The way we've configured 'smarttab' and 'softtabstop', we can now entirely
-- configure how Vim handles tabs, in all contexts, with a single option:
-- 'shiftwidth'.

-- Show invisible characters
opt.list = true

opt.listchars = {
  -- TAB character
  --
  --     ┌ always used
  --     │┌ as many times as will fit
  tab = '▸ ',

  -- no-break space
  nbsp = '∅',

  -- trailing whitespace
  trail = '·',

  -- end of line (it's annoying to display all the time)
  -- eol = "↴",
}

-- Prevent the screen from being redrawn while executing commands which haven't
-- been typed (e.g.: macros, registers).
-- Also, postpone the update of the window title.
--
-- Because of this option, sometimes, we might need to execute `:redraw` in a
-- (function called by a) mapping.
opt.lazyredraw = true

-- Enable mouse in all modes
opt.mouse = 'a'

-- Use the 'numberwidth' option to adjust the room for the line number.

-- Print the line number in front of each line
opt.number = true

-- Display at least 'n' lines above/below the cursor
opt.scrolloff = 5

-- ignore the case when searching for a pattern containing only lowercase characters
opt.ignorecase = true

-- but don't ignore the case if it contains an uppercase character
opt.smartcase = true

opt.shortmess:append {
  a = true, -- Enable all sorts of abbreviations in messages
  c = true, -- Don't print |ins-completion-menu| messages
  I = true, -- Disable the default Vim startup message
  t = true, -- Truncate file messages at start
  W = true, -- Don't give "written" or "[w]" when writing a file
}

-- A margin between the left of the screen and the text to display signs
--
-- Used by:
--
--   - builtin-in lsp
--   - gitsigns.nvim
opt.signcolumn = 'yes:1'

-- Global statusline
opt.laststatus = 3

-- Disable swap files, living on the edge!
opt.swapfile = false

-- Enable persistent undo
opt.undofile = true

-- Set the title of the window to the value of 'titlestring'
opt.title = true

-- Set the custom title string
opt.titlestring = "nvim: %t (%{fnamemodify(getcwd(), ':t')})"

-- Wait for 'n' number of milliseconds before executing `CursorHold`
opt.updatetime = 300

-- What does `vim.opt.wildcharm = 26` imply?{{{
--
-- Definition:
--
--   - 'wildchar': the key to press for Vim to start a wildcard expansion
--     (which opens the widmenu)
--   - 'wildcharm': the key to press for Vim to start a wildcard expansion from
--     - the recording of a macro
--     - the rhs of a mapping
--
-- When you want Vim to start a wildcard expansion, in the rhs of a mapping or
-- while recording a macro, you must use '<C-Z>'.
-- }}}
opt.wildcharm = 26

-- The value of 'wildmode' is a comma-separated list of (up to 4) parts.
-- Each part defines what happens when we press Tab (&wildchar) the
-- 1st/2nd/3rd/4th time.
opt.wildmode = {
  -- complete longest common string : show the wildmenu
  'longest:full',

  -- start completing each full match
  'full',
}

-- When we create a new horizontal viewport, it should be displayed at the
-- bottom of the screen
opt.splitbelow = true

-- and a new vertical one should be displayed on the right
opt.splitright = true

-- Squash an unfocused window to 0 lines/columns (useful when we zoom a window
-- with `<leader>z`)
opt.winminheight = 0
opt.winminwidth = 0

-- A soft-wrapped line should be displayed with the same level of indentation
-- as the first one.
opt.breakindent = true

opt.breakindentopt = {
  -- Display the 'showbreak' value before applying the additional indent
  'sbr',
}

-- soft-wrap long lines at a character in 'breakat' (punctuation, math operators,
-- tab, @) rather than at the last character that fits on the screen
opt.linebreak = true

-- Alternatives: "↳ ", "››› ", "↪ "
opt.showbreak = '↳ '

-- do not automatically wrap text
opt.textwidth = 0

-- Visually wrap lines longer than window width
opt.wrap = true
