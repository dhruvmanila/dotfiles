" Utility functions

" Report the highlight groups active at the current point.
" Ref: https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
function! utils#highlight_groups() abort
  let l:hi = synIDattr(synID(line('.'), col('.'), 1), 'name')
  let l:trans = synIDattr(synID(line('.'), col('.'), 0), 'name')
  let l:lo = synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
  echo 'hi<' . l:hi . '> trans<' . l:trans . '> hi<' . l:hi . '>'
endfunction
