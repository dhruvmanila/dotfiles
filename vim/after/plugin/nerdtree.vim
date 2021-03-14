" " Ref: https://github.com/preservim/nerdtree
"
" " Close NERDTree on opening the file
" let g:NERDTreeQuitOnOpen = 1
"
" " Automatically delete the buffer of the file you just deleted with NerdTree
" let g:NERDTreeAutoDeleteBuffer = 1
"
" " Disables display of 'Bookmarks' label and 'Press ? for help' text.
" let g:NERDTreeMinimalUI = 1
"
" " Use a smaller, more compact menu (on a single line)
" let g:NERDTreeMinimalMenu = 1
"
" " Show hidden files
" let g:NERDTreeShowHidden = 1
"
" " Ignore files in NERDTree
" let g:NERDTreeIgnore = [
"       \ '\.git$',
"       \ '\.DS_Store',
"       \ '\.pyc$',
"       \ '\.pyo$',
"       \ '__pycache__$',
"       \ '\.mypy_cache$',
"       \ ]
"
" " 1. Close vim if only window left is NERDTree
" " 2. Load NERDTree and startify if vim is ran without arguments
" " 3. Disable signcolumn in NERDTree
" augroup nerdtree
"   autocmd!
"   autocmd BufEnter *
"         \ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree())
"         \ | q
"         \ | endif
"   " autocmd VimEnter *
"   "       \ if !argc()
"   "       \ | Startify
"   "       \ | NERDTree
"   "       \ | wincmd w
"   "       \ | endif
"   autocmd FileType nerdtree setlocal signcolumn=no
" augroup END
"
" nnoremap <C-n> :NERDTreeToggle<CR>
" nnoremap <Leader>f :NERDTreeFind<CR>
