local o = vim.o
local bo = vim.bo
local wo = vim.wo

o.mouse = 'nv'           -- Enable mouse in Normal and Visual mode
o.hidden = true          -- Allow buffers to be hidden
o.lazyredraw = true
o.splitbelow = true      -- Default horizontal split on below
o.splitright = true      -- Default vertical split on right
o.scrolloff = 12         -- Keep the cursor in the middle area approx
o.showcmd = true         -- Show command as typed
o.termguicolors = true
o.updatetime = 100
o.clipboard = 'unnamed'  -- Use OS clipboard
o.ignorecase = true      -- Ignore case in search by default...
o.smartcase = true       -- Unless an uppercase letter is present
o.ruler = false

-- I: Disable the default Vim startup message
-- c: Don't give messages like "The only match", "Pattern not found", etc.
o.shortmess = o.shortmess .. 'Ic'

-- Complete longest common string : show the wildmenu then start completing
-- each full match
o.wildmode = 'longest:full,full'

-- wo.list = true
-- o.listchars = 'tab:▸ ,nbsp:_,trail:·,eol:↴'

wo.colorcolumn = '80'
wo.cursorline = true
wo.number = true
wo.relativenumber = true
wo.signcolumn = 'yes:1'    -- Show signcolumn of 1 character wide

wo.wrap = true         -- Visually wrap lines longer than window width
wo.breakindent = true  -- Every wrapped line will continue visually indented
o.showbreak = '↳ '
wo.linebreak = true    -- Wrapped lines preserve horizontal blocks of text

-- Default settings (should be changed as per filetype)
bo.expandtab = true
bo.shiftwidth = 2
bo.tabstop = 2

-- Format options:
-- 'c': Comments should respect textwidth
-- 'q': Allow formatting of comments with 'gq'
-- 'r': Continue comments when pressing Enter in Insert mode
-- 'j': When it makes sense, remove a comment Leader when joining lines.
-- 'n': Use hanging indent on numbered list (formatlistpat)
bo.formatoptions = 'cqrjn'

bo.swapfile = false
bo.undofile = true

-- Cursor Shape (:h guicursor)
