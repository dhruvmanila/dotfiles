call nvim_win_set_cursor(0, [7, 0]) " Set the cursor to About section
setlocal signcolumn=no

" Quick edit the cheat40.txt file
function! s:edit_cheat40()
  let filepath = stdpath('config') . '/cheat40.txt'
  exe 'edit ' . filepath
  " Give some extra editing space
  vertical resize +10
  setlocal signcolumn=no
  setlocal nonumber
  setlocal norelativenumber
  " Useful abbreviations
  iabbrev <buffer> <c «C-»<left>
  iabbrev <buffer> <s «Spc»
  iabbrev <buffer> < ‹›<left>
  nnoremap <buffer><nowait><silent> q :bd<CR>
endfunction

nnoremap <buffer><nowait><silent> e :call <SID>edit_cheat40()<CR>
nnoremap <buffer><nowait><silent> <space> za
