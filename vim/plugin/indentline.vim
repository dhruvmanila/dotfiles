let g:indentLine_char = '¦' " | ¦ ┆ │

let g:indentLine_fileTypeExclude = [
      \ 'startify',
      \ 'help',
      \ 'nerdtree',
      \ ]

" Use colors from the colorscheme
if g:vim_color_scheme ==# 'vim-monokai-tasty'
  let g:indentLine_setColors = 1
else
  let g:indentLine_setColors = 0
endif

" Show quotes in JSON file
augroup json_conceal_level
  autocmd!
  autocmd BufEnter,BufWinEnter *.json let g:indentLine_setConceal = 0
  autocmd BufLeave,BufWinLeave *.json let g:indentLine_setConceal = 1
augroup END
