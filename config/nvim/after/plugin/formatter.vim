" Description: Custom formatter setup
" Maintainer:  Dhruv Manilawala <http://github.com/dhruvmanila>

if exists('g:loaded_formatter')
  finish
endif
let g:loaded_formatter = 1

function! s:toggle_auto_formatting()
  augroup auto_formatting
    autocmd!
  augroup END
  let s:auto_formatting = get(s:, 'auto_formatting', 0) ? 0 : 1
  if !s:auto_formatting
    echo "[formatter] Auto formatting: OFF"
    return
  endif
  echo "[formatter] Auto formatting: ON"
  augroup auto_formatting
    autocmd BufWritePost * lua require('dm.formatter.format').format()
  augroup END
endfunction

" By default, auto formatting is turned on.
call s:toggle_auto_formatting()

command! -nargs=0 AutoFormatting call <SID>toggle_auto_formatting()
command! -nargs=0 Format lua require('dm.formatter.format').format()

nnoremap ;f <Cmd>Format<CR>
