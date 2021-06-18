local opt = vim.opt

opt.autoindent = true -- copy indent from current line when starting a new line
opt.breakindent = true -- every wrapped line will continue visually indented

opt.clipboard = { "unnamed" } -- use OS clipboard
opt.cmdheight = 1

opt.completeopt = {
  "menuone", -- show menu even if there is only one match
  "noinsert", -- do not select any text until the user selects a match from the menu
  "noselect", -- do not select a match in the menu, force the user to select one
}

opt.copyindent = true -- copy the structure of existing lines indent
opt.cursorline = true

opt.diffopt:append {
  "vertical", -- start diff mode with vertical splits
}

opt.emoji = false -- https://www.youtube.com/watch?v=F91VWOelFNE
opt.expandtab = true -- use spaces intead of TAB

opt.formatoptions = {
  c = true, -- comments should respect textwidth
  q = true, -- allow formatting of comments with 'gq'
  r = true, -- continue comments when pressing Enter in Insert mode
  j = true, -- when it makes sense, remove a comment Leader when joining lines.
  n = true, -- use hanging indent on numbered list (formatlistpat)
}

-- Set the default grep program to ripgrep if available
if vim.fn.executable "rg" then
  opt.grepprg = "rg --vimgrep"
  opt.grepformat:prepend { "%f:%l:%c:%m" }
end

opt.hidden = true -- allow buffers to be hidden
opt.ignorecase = true -- ignore case in search by default
opt.inccommand = "nosplit" -- shows the effects of a command incrementally
opt.laststatus = 2 -- always show statusline
opt.lazyredraw = true
opt.linebreak = true -- Wrapped lines preserve horizontal blocks of text

-- Show invisible characters
opt.list = true
opt.listchars = {
  tab = "▸ ",
  nbsp = "_",
  trail = "·",
  -- eol = "↴",
}

opt.mouse = "a" -- enable mouse in all modes
opt.number = true

opt.pumblend = vim.g.window_blend
opt.pumheight = 20

opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 5 -- Keep the cursor in the middle area approx
opt.shiftround = true -- round indent to multiple of 'shiftwidth'
opt.shiftwidth = 2 -- number of spaces of an indent

opt.shortmess:append {
  I = true, -- disable the default Vim startup message
  c = true, -- don't give messages like "The only match", "Pattern not found", etc.
  a = true, -- use all abbreviations in messages
}

opt.showbreak = "↳ " -- downwards arrow with tip rightwards (U+21B3, UTF-8: E2 86 B3)
opt.showcmd = true -- show incomplete command as typed
opt.showmode = true
opt.showtabline = 2 -- always show tabline

opt.signcolumn = "yes:1"
opt.smartcase = true -- unless an uppercase letter is present

opt.splitbelow = true -- default horizontal split on below
opt.splitright = true -- default vertical split on right

opt.swapfile = false
opt.synmaxcol = 200
opt.tabstop = 2 -- number of spaces that a TAB counts for
opt.termguicolors = true
opt.textwidth = 0 -- do not automatically wrap text
opt.undofile = true
opt.updatetime = 100

-- Complete longest common string : show the wildmenu,
-- start completing each full match
opt.wildmode = "longest:full,full"

opt.wrap = true -- visually wrap lines longer than window width
