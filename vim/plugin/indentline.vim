let g:indentLine_char = '¦' " | ¦ ┆ │

let g:indentLine_fileTypeExclude = [
      \ 'startify',
      \ 'help',
      \ ]

" Use colors from the colorscheme
if g:vim_color_scheme ==# 'vim-monokai-tasty'
  let g:indentLine_setColors = 1
else
  let g:indentLine_setColors = 0
endif
