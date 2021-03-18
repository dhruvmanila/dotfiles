" Ref: https://github.com/mhinz/vim-startify

nnoremap <Leader>` :Startify<CR>

augroup start_startify_on_vim_startup
  autocmd!
  autocmd VimEnter * if !argc() | Startify | endif
augroup END

" Startify header
let g:ascii_vim = [
      \ '',
      \ '              ██╗   ██╗██╗███╗   ███╗',
      \ '              ██║   ██║██║████╗ ████║',
      \ '              ██║   ██║██║██╔████╔██║',
      \ '              ╚██╗ ██╔╝██║██║╚██╔╝██║',
      \ '               ╚████╔╝ ██║██║ ╚═╝ ██║',
      \ '                ╚═══╝  ╚═╝╚═╝     ╚═╝',
      \ ''
      \ ]

let g:startify_custom_header =
      \ 'startify#pad(g:ascii_vim + startify#fortune#boxed())'

let g:startify_lists = [
      \ {'type': 'dir',       'header': ['   Current Directory '. getcwd()]},
      \ {'type': 'files',     'header': ['   Files']},
      \ {'type': 'sessions',  'header': ['   Sessions']},
      \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
      \ ]

let g:startify_bookmarks = [
      \ {'v': '~/dotfiles/vim/vimrc'},
      \ {'b': '~/dotfiles/bash/bashrc'},
      \ {'d': '~/dotfiles/bin/dot'},
      \ {'t': '~/dotfiles/tmux/tmux.conf'},
      \ {'g': '~/dotfiles/assets/gitconfig'}
      \ ]

" Automatically update sessions before leaving Vim and before loading a new
" session via :SLoad
let g:startify_session_persistence = 1

let g:startify_session_delete_buffers = 1

" When opening a file or bookmark, do not change the PWD
let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 0

" Close NERDTree tabs before saving a session and get the buffer back to the
" original tabpage.
" let g:startify_session_before_save = [
"       \ 'let $CURRENT_TABPAGE = tabpagenr()',
"       \ 'tabdo NERDTreeClose',
"       \ 'execute $CURRENT_TABPAGE . "tabnext"',
"       \ ]