" Ref: https://github.com/mhinz/vim-startify

nnoremap <silent> <Leader>` :Startify<CR>

" Startify header
let g:ascii_vim = [
      \ '',
      \ '     ____  ___  ____ _   __(_)___ ___    ',
      \ '    / __ \/ _ \/ __ \ | / / / __ `__ \   ',
      \ '   / / / /  __/ /_/ / |/ / / / / / / /   ',
      \ '  /_/ /_/\___/\____/|___/_/_/ /_/ /_/    ',
      \ '',
      \ ]

let g:startify_custom_header =
      \ 'startify#pad(g:ascii_vim + startify#fortune#boxed())'

let g:startify_lists = [
      \ {'type': 'dir',       'header': ['   Current Directory '. getcwd()]},
      \ {'type': 'files',     'header': ['   Files']},
      \ {'type': 'sessions',  'header': ['   Sessions']},
      \ {'type': 'bookmarks', 'header': ['   Bookmarks']},
      \ {'type': 'commands',  'header': ['   Commands']},
      \ ]

let g:startify_bookmarks = [
      \ {'v': '~/dotfiles/vim/vimrc'},
      \ {'b': '~/dotfiles/bash/bashrc'},
      \ {'d': '~/dotfiles/bin/dot'},
      \ {'t': '~/dotfiles/tmux/tmux.conf'},
      \ {'g': '~/dotfiles/assets/gitconfig'},
      \ ]

let g:startify_commands = [
      \ {'ps': ':PackerSync'},
      \ {'pi': ':PackerInstall'},
      \ {'pc': ':PackerCompile'},
      \ ]

" Automatically update sessions before leaving Vim and before loading a new
" session via :SLoad
let g:startify_session_persistence = 1

let g:startify_session_delete_buffers = 1

" When opening a file or bookmark, do not change the PWD
let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 0
