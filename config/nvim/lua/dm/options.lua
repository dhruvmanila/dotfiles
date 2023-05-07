local opt = vim.opt

-- cmdline: mode, ruler {{{1

-- When `'statusline'` is empty, Vim displays the current line address, and
-- column number, in the statusline. This region is called the “ruler bar“
-- (`:help ruler`).
--
-- Even though we should never see it, disable it explicitly.
opt.ruler = false

-- NOTE: If on, it can erase a message ouput by `:echo` or `:lua print`
opt.showmode = false

-- clipboard {{{1

-- Use OS clipboard
--
--   > To ALWAYS use the clipboard for ALL operations (instead of interacting with
--   > the '+' and/or '*' registers explicitly)
--   >
--   >    `set clipboard+=unnamedplus`
--
-- `:h provider-clipboard`
opt.clipboard:append 'unnamedplus'

-- completion {{{1

opt.completeopt = {
  -- show menu even if there is only one match
  'menuone',
  -- do not select any text until the user selects a match from the menu
  'noinsert',
}

-- Maxmimum number of items to show in the popup menu (|inc-completion-menu|)
opt.pumheight = 20

-- colorscheme {{{1

-- Enables 24-bit RGB colors. This will use the 'gui' highlight attributes
-- instead of 'cterm' attributes.
vim.opt.termguicolors = true

-- Custom colorscheme providing only the required highlight groups and thus
-- reducing the startup time.
vim.cmd 'colorscheme gruvbox'

-- diffopt {{{1

opt.diffopt:append {
  -- Use the indent heuristic for the  internal diff library, because it gives
  -- more readable diffs.
  -- See: https://vimways.org/2018/the-power-of-diff/
  'indent-heuristic',

  -- Start diff mode with vertical splits (unless explicitly specified otherwise)
  'vertical',
}

-- emoji {{{1

-- Might fix various issues when editing a line containing some emojis.
--
-- See: https://www.youtube.com/watch?v=F91VWOelFNE&t=174s
opt.emoji = false

-- exrc {{{1

opt.exrc = true

-- fillchars {{{1

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

-- format: options, listpat {{{1

-- 'formatoptions' handles the automatic formatting of text.
opt.formatoptions = {
  -- comments should respect textwidth
  c = true,

  -- allow formatting of comments with 'gq'
  q = true,

  -- insert comment leader when pressing Enter in Insert mode
  r = true,

  -- where it makes sense, remove a comment Leader when joining lines.
  j = true,

  -- when formatting text, use 'formatlistpat' to recognize numbered lists
  -- IOW, use hanging indent on ordered/unordered list
  n = true,
}

-- A pattern that is used to recognize a list header. This is used for the "n"
-- flag in 'formatoptions'.
--                           ┌ recognize numbered lists (default)
--                           ├─────────────┐
opt.formatlistpat = [[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\)\s*]]
--                                            ├───┘
--                                            └ recognize unordered lists

-- folding {{{1

-- Treesitter based folding (requires 'foldmethod=expr')
-- opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Default fold method is marker for now.
opt.foldmethod = 'marker'

-- Close a fold even if it doesn't contain any line.
opt.foldminlines = 0

-- grep {{{1

-- Define rg as the program to call when using the Ex commands: `:[l]grep[add]`.
opt.grepprg = 'rg --vimgrep'

-- Define how the output of rg must be parsed:
--
--                         ┌ filename
--                         │  ┌ line number
--                         │  │  ┌ column number
--                         │  │  │  ┌ error message
--                         │  │  │  │
opt.grepformat:prepend { '%f:%l:%c:%m' }

-- indentation {{{1

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

-- invisible characters: listchars {{{1

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

-- lazyredraw {{{1

-- Prevent the screen from being redrawn while executing commands which haven't
-- been typed (e.g.: macros, registers).
-- Also, postpone the update of the window title.
--
-- Because of this option, sometimes, we might need to execute `:redraw` in a
-- (function called by a) mapping.
opt.lazyredraw = true

-- mouse {{{1

-- Enable mouse in all modes
opt.mouse = 'a'

-- number {{{1

-- Use the 'numberwidth' option to adjust the room for the line number.

-- Print the line number in front of each line
opt.number = true

-- Show the line number relative to the line with the cursor.
opt.relativenumber = true

-- scroll {{{1

-- Display at least 'n' lines above/below the cursor
opt.scrolloff = 5

-- search {{{1

-- ignore the case when searching for a pattern containing only lowercase characters
opt.ignorecase = true

-- but don't ignore the case if it contains an uppercase character
opt.smartcase = true

-- shortmess {{{1

opt.shortmess:append {
  -- Enable all sorts of abbreviations in messages
  a = true,

  -- Don't print |ins-completion-menu| messages. For example: {{{
  --
  --    - "-- XXX completion (YYY)"
  --    - "match 1 of 2"
  --    - "The only match"
  --    - "Pattern not found"
  --    - "Back at original"
  -- }}}
  c = true,

  -- Disable the default Vim startup message
  I = true,
}

-- signcolumn {{{1

-- A margin between the left of the screen and the text to display signs
--
-- Used by:
--
--   - builtin-in lsp
--   - gitsigns.nvim
opt.signcolumn = 'yes:1'

-- statusline {{{1

-- Global statusline
opt.laststatus = 3

-- synmaxcol {{{1

-- Don't syntax highlight long lines (Vim will become slow)
opt.synmaxcol = 500
--               │
--               └ weight in bytes
--                 any character prefixed by a string heavier than that
--                 will NOT be syntax highlighted

-- temporary files: undo, swap, backup {{{1

-- Disable swap files, living on the edge!
opt.swapfile = false

-- Enable persistent undo
opt.undofile = true

-- title {{{1

-- Set the title of the window to the value of 'titlestring'
opt.title = true

-- Set the custom title string
opt.titlestring = "nvim: %t (%{fnamemodify(getcwd(), ':t')})"

-- updatetime {{{1

-- Wait for 'n' number of milliseconds before executing `CursorHold`
opt.updatetime = 100

-- wildmenu / wildcharm {{{1

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

-- window {{{1

-- When we create a new horizontal viewport, it should be displayed at the
-- bottom of the screen
opt.splitbelow = true

-- and a new vertical one should be displayed on the right
opt.splitright = true

-- Squash an unfocused window to 0 lines/columns (useful when we zoom a window
-- with `<leader>z`)
opt.winminheight = 0
opt.winminwidth = 0

-- word / line wrapping {{{1

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
