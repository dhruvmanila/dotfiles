local opt = require('core.utils').opt

opt.mouse         = 'nv'       -- Enable mouse in Normal and Visual mode
opt.hidden        = true       -- Allow buffers to be hidden
opt.lazyredraw    = true
opt.splitbelow    = true       -- Default horizontal split on below
opt.splitright    = true       -- Default vertical split on right
opt.scrolloff     = 12         -- Keep the cursor in the middle area approx
opt.showcmd       = true       -- Show command as typed
opt.termguicolors = true
opt.updatetime    = 100
opt.clipboard     = 'unnamed'  -- Use OS clipboard
opt.ignorecase    = true       -- Ignore case in search by default...
opt.smartcase     = true       -- Unless an uppercase letter is present
opt.ruler         = true       -- TODO: Disable once statusline is configured

-- I: Disable the default Vim startup message
-- c: Don't give messages like "The only match", "Pattern not found", etc.
opt.shortmess = opt.shortmess .. 'Ic'

-- Complete longest common string : show the wildmenu then start completing
-- each full match
opt.wildmode = 'longest:full,full'

-- menuone: show menu even if there is only one match
-- preview: show extra information about selection in preview window
-- noinsert: do not select any text until the user selects a match from the menu
-- noselect: do not select a match in the menu, force the user to select one
opt.completeopt = 'menuone,preview,noinsert,noselect'

opt.list = true
opt.listchars = [[tab:▸ ,nbsp:_,trail:·,eol:↴]]

opt.colorcolumn    = '80'
opt.cursorline     = true
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = 'yes:1'
opt.foldenable     = false
opt.pumheight      = 15

opt.wrap        = true  -- Visually wrap lines longer than window width
opt.breakindent = true  -- Every wrapped line will continue visually indented
opt.showbreak   = '↳ '
opt.linebreak   = true  -- Wrapped lines preserve horizontal blocks of text

-- Default settings (should be changed as per filetype)
opt.expandtab  = true
opt.shiftwidth = 2
opt.tabstop    = 2

-- Format options:
-- 'c': Comments should respect textwidth
-- 'q': Allow formatting of comments with 'gq'
-- 'r': Continue comments when pressing Enter in Insert mode
-- 'j': When it makes sense, remove a comment Leader when joining lines.
-- 'n': Use hanging indent on numbered list (formatlistpat)
opt.formatoptions = 'cqrjn'

opt.swapfile = false
opt.undofile = true

-- Cursor Shape (:h guicursor)
