" Description: Personal start screen for neovim written in lua :)
" Maintainer:  Dhruv <http://github.com/dhruvmanila>

if exists('g:loaded_dashboard') || &cp
  finish
endif

let g:loaded_dashboard = 1

" Disable Startify start screen and only keep the session management stuff
let g:startify_disable_at_vimenter = 1
let g:startify_update_oldfiles = 0

let g:startify_session_dir = stdpath("data") .. "/session"
let g:startify_session_persistence = 1
let g:startify_session_delete_buffers = 1
let g:startify_session_autoload = 0
let g:startify_session_sort = 0

let g:startify_session_before_save = [
      \ 'lua require("dm.dashboard").session_cleanup()',
      \ ]

augroup dashboard
  autocmd!
  autocmd VimEnter * nested call s:on_vimenter()
  autocmd VimResized * if &ft ==# 'dashboard' | Dashboard | endif
augroup END

function! s:on_vimenter()
  if !argc() && line2byte('$') == -1
    lua require('dm.dashboard').open(true)
  endif
  autocmd! dashboard VimEnter
endfunction

silent autocmd! startify QuickFixCmdPre
silent autocmd! startify QuickFixCmdPost
silent delcommand Startify

command! -nargs=0 -bar Dashboard lua require('dm.dashboard').open(false)
command! -nargs=0 -bar Startify Dashboard

nnoremap <silent> <leader>` <Cmd>Dashboard<CR>
