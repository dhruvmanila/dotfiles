" Utility functions

" Report the highlight groups active at the current point.
" Ref: https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
function! utils#highlight_groups() abort
  let l:hi    = synIDattr(synID(line('.'), col('.'), 1), 'name')
  let l:trans = synIDattr(synID(line('.'), col('.'), 0), 'name')
  let l:lo    = synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
  echo 'hi<' . l:hi . '> trans<' . l:trans . '> hi<' . l:hi . '>'
endfunction

" Trim trailing whitespace in the current file.
" This will save the current view of the window and restore it back after the process.
function! utils#trim_trailing_whitespace() abort
  let l:saved = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:saved)
endfunction

" Trim blank lines at the end of the file.
" This will save the current view of the window and restore it back after the process.
function! utils#trim_trailing_lines() abort
  let l:saved = winsaveview()
  let l:last_line = line('$')
  let l:last_non_blank_line = prevnonblank(l:last_line)
  if l:last_non_blank_line > 0 && l:last_line != l:last_non_blank_line
    silent! execute l:last_non_blank_line + 1 . ',$delete _'
  endif
  call winrestview(l:saved)
endfunction
