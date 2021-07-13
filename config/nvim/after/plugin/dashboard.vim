" Description: Personal start screen for neovim written in lua :)
" Maintainer:  Dhruv <http://github.com/dhruvmanila>

if exists('g:loaded_dashboard') || &cp
  finish
endif

let g:loaded_dashboard = 1

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

command! -nargs=0 -bar Dashboard lua require('dm.dashboard').open(false)

nnoremap <silent> <leader>` <Cmd>Dashboard<CR>
