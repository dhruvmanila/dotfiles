if exists('+termguicolors')
  set termguicolors
  " The commands below are needed for tmux + termguicolors
  " This is only necessary if you use "set termguicolors".
  let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
  let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
endif

set ttyfast             " Improve redrawing
set lazyredraw

set cursorline
set number              " show line numbers
set relativenumber      " show relative numbering
set signcolumn=yes      " show sign column
set textwidth=0         " no auto formatting when reached at textwidth
set colorcolumn=80      " but highlight the limit

set wrap                " Visually wrap lines outside the window width
let &showbreak='↳ '
set breakindent         " Wrapped lines preserve horizontal blocks of text
set breakindentopt=sbr
set linebreak           " Have lines wrap instead of continue off-screen

set showcmd             " Show the command being typed in

set expandtab           " Expand tabs to spaces
set shiftwidth=2        " Default settings
set tabstop=2           " Default settings
set autoindent

" set list                " Show the invisible symbols
set listchars=tab:▸\      " Use custom symbols to
set listchars+=trail:·    " represent invisible symbols
set listchars+=eol:↴
set listchars+=nbsp:_

set showmatch           " Jump to matching [{()}] for 'matchtime'

set laststatus=2        " Always show statusline
" set showtabline=2       " and tabline

set mouse+=a            " Enable mouse support

" Disable annoying error noises
set noerrorbells
set visualbell
set t_vb=

set splitbelow          " Open new vertical split bottom
set splitright          " Open new horizontal splits right

set scrolloff=12        " Keep cursor in approximately the middle of the screen

set updatetime=100      " Some plugins require fast updatetime
set ttimeout
set ttimeoutlen=10

" I: Disable the default Vim startup message
" c: Don't give messages like "The only match", "Pattern not found", etc.
set shortmess+=Ic

set nostartofline       " Don't set cursor to start of line when moving around

set title               " Show the filename in window titlebar

" Tab completion for files/buffers
set wildmenu                " Visual autocomplete for command menu
set wildmode=longest:full   " Complete longest common string : show the wildmenu
set wildmode+=full          " then start completing each full match

" Use the system clipboard as the default register
set clipboard=unnamed

set encoding=utf-8
set autoread            " Reload files when changed on disk
set hidden              " Allows having hidden buffer (not displayed in any window)
set backspace=indent,eol,start    " Allow backspace in insert mode

set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase          " Ignore case in searches by default
set smartcase           " But make it case sensitive if an uppercase is entered

" Format options
" 'r': Automatically insert the current comment Leader after hitting <Enter> in
" Insert mode.
" 'j': When it makes sense, remove a comment Leader when joining lines.
set formatoptions+=rj

set showmode          " Why reinvent the wheel?
set noruler           " Cursor position

set nobackup
set noswapfile
set undofile
set undodir=~/.vim/undo/

" Cursor Shape: https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
" 0 -> Solid block
" 1 -> Solid vertical bar
" 2 -> Solid underscore
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"  " INSERT
  let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"  " REPLACE
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"  " NORMAL (ELSE)
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_SR = "\<Esc>]50;CursorShape=2\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
