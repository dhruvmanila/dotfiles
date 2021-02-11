" Automatically delete the buffer of the file you just deleted with NerdTree
let NERDTreeAutoDeleteBuffer = 1

" Disables display of 'Bookmarks' label and 'Press ? for help' text.
let NERDTreeMinimalUI = 1

" Show hidden files
let NERDTreeShowHidden = 1

" Ignore files in NERDTree
let NERDTreeIgnore = [
      \ '\.git$',
      \ '\.DS_Store',
      \ '\.pyc$',
      \ '\.pyo$',
      \ '__pycache__$',
      \ '\.mypy_cache$',
      \ ]

" 1. Close vim if only window left is NERDTree
" 2. Load NERDTree and startify if vim is ran without arguments
" 3. Disable signcolumn in NERDTree
augroup nerdtree
  autocmd!
  autocmd BufEnter *
        \ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree())
        \ | q
        \ | endif
  autocmd VimEnter *
        \ if !argc()
        \ | Startify
        \ | NERDTree
        \ | wincmd w
        \ | endif
  autocmd FileType nerdtree setlocal signcolumn=no
augroup END

" NOTE: Make all windows the same width whenever a NERDTree is opened or closed
" but do not change the height. This is done using `SetWindowsToEqualWidth()`.
" The function was sourced from the vimrc file.

" Set key to Ctrl-n to open nerd tree.
nnoremap <C-n> :NERDTreeToggle<CR> :call SetWindowsToEqualWidth()<CR>
nnoremap <C-f> :NERDTreeFind<CR> :call SetWindowsToEqualWidth()<CR>
" Change focus to the NERDTree window if present, else open it.
" This will help in opening a file in a specific buffer, otherwise it opens
" the file in the first buffer from the NERDTree window.
nnoremap <leader>n :NERDTreeFocus<CR> :call SetWindowsToEqualWidth()<CR>
