" Ref: https://github.com/preservim/nerdcommenter

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Allow commenting and inverting empty lines
let g:NERDCommentEmptyLines = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Custom delimiters for filetype
let g:NERDCustomDelimiters = {
      \ 'racket': { 'left': ';;', 'nested': 1, 'leftAlt': '#|', 'rightAlt': '|#', 'nestedAlt': 1 }
      \ }
