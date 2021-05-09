local opt = require("core.utils").opt

opt.mouse = "nv" -- Enable mouse in Normal and Visual mode
opt.hidden = true -- Allow buffers to be hidden
opt.lazyredraw = true
opt.splitbelow = true -- Default horizontal split on below
opt.splitright = true -- Default vertical split on right
opt.scrolloff = 5 -- Keep the cursor in the middle area approx
opt.showcmd = true -- Show incomplete command as typed
opt.termguicolors = true
opt.updatetime = 100
opt.clipboard = "unnamed" -- Use OS clipboard
opt.ignorecase = true -- Ignore case in search by default...
opt.smartcase = true -- Unless an uppercase letter is present
opt.ruler = false
opt.showmode = true
opt.emoji = false -- https://www.youtube.com/watch?v=F91VWOelFNE
opt.synmaxcol = 200
opt.inccommand = "nosplit" -- shows the effects of a command incrementally

opt.cmdheight = 1
opt.laststatus = 2 -- Always show statusline
opt.showtabline = 2 -- Always show tabline

-- I: Disable the default Vim startup message
-- c: Don't give messages like "The only match", "Pattern not found", etc.
opt.shortmess = opt.shortmess .. "Ic"

-- Complete longest common string : show the wildmenu,
-- start completing each full match
opt.wildmode = "longest:full,full"

-- menuone: show menu even if there is only one match
-- noinsert: do not select any text until the user selects a match from the menu
-- noselect: do not select a match in the menu, force the user to select one
opt.completeopt = "menuone,noinsert,noselect"
opt.pumheight = 20
opt.pumblend = 15

-- Set the default grep program to ripgrep if available
opt.grepformat = "%f:%l:%c:%m," .. opt.grepformat
if vim.fn.executable("rg") then
  opt.grepprg = "rg --vimgrep"
end

-- vertical: start diff mode with vertical splits
opt.diffopt = opt.diffopt .. ",vertical"

-- Show invisible characters
opt.list = true
opt.listchars = [[tab:▸ ,nbsp:_,trail:·]] -- ,eol:↴]]

opt.colorcolumn = "80"
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes:1"
opt.foldenable = false

opt.wrap = true -- Visually wrap lines longer than window width
opt.breakindent = true -- Every wrapped line will continue visually indented
opt.showbreak = "↳ "
opt.linebreak = true -- Wrapped lines preserve horizontal blocks of text
opt.autoindent = true -- copy indent from current line when starting a new line
opt.copyindent = true -- copy the structure of existing lines indent

-- Default settings (should be changed as per filetype)
opt.expandtab = true -- use spaces intead of TAB
opt.shiftround = true -- round indent to multiple of 'shiftwidth'
opt.shiftwidth = 2 -- number of spaces of an indent
opt.tabstop = 2 -- number of spaces that a TAB counts for
opt.textwidth = 0 -- Do not automatically wrap text

-- Format options:
-- 'c': Comments should respect textwidth
-- 'q': Allow formatting of comments with 'gq'
-- 'r': Continue comments when pressing Enter in Insert mode
-- 'j': When it makes sense, remove a comment Leader when joining lines.
-- 'n': Use hanging indent on numbered list (formatlistpat)
opt.formatoptions = "cqrjn"

opt.swapfile = false
opt.undofile = true

-- Cursor Shape (:h guicursor)
