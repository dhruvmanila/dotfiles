" Ref: https://github.com/Yggdroot/indentLine

let g:indentLine_char = '¦' " | ¦ ┆ │ ┊

let g:indentLine_showFirstIndentLevel = 0
" let g:indentLine_concealcursor = ""

let g:indentLine_fileTypeExclude = [
      \ 'startify',
      \ 'help',
      \ 'nerdtree',
      \ ]

" Use colors from the colorscheme
if g:colors_name ==# 'vim-monokai-tasty'
  let g:indentLine_setColors = 1
else
  let g:indentLine_setColors = 0
endif
