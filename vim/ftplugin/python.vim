setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=8

" python-syntax
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable all syntax highlighting features
let python_highlight_all = 1

" ALE
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Check Python files with flake8 and mypy.
let b:ale_linters = ['flake8', 'mypy']

" Fix Python files with black
let b:ale_fixers = ['black']

" Disable warnings about trailing whitespace for Python files.
" let b:ale_warn_about_trailing_whitespace = 0

" NERDCommenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
