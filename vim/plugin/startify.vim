" Disable startify header
let g:startify_custom_header = []

let g:startify_lists = [
      \ {'type': 'files',     'header': ['   Files']},
      \ {'type': 'dir',       'header': ['   Current Directory '. getcwd()]},
      \ {'type': 'sessions',  'header': ['   Sessions']},
      \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
      \ ]

let g:startify_bookmarks = [
      \ {'v': '~/dotfiles/vim/vimrc'},
      \ {'b': '~/dotfiles/bash/bashrc'},
      \ ]

" Automatically update sessions before leaving Vim and before loading a new
" session via :SLoad
let g:startify_session_persistence = 1

let g:startify_session_delete_buffers = 1

" When opening a file or bookmark, seek and change to the git root directory
" if any and not to the file directory.
let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 1

" Close NERDTree tabs before saving a session and get the buffer back to the
" original tabpage.
let g:startify_session_before_save = [
      \ 'let $CURRENT_TABPAGE = tabpagenr()',
      \ 'tabdo NERDTreeClose',
      \ 'execute $CURRENT_TABPAGE . "tabnext"',
      \ ]
