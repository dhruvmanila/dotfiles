setlocal nonumber
setlocal norelativenumber
setlocal nolist

" If there is a NvimTree window, then the limit should be 3.
let s:limit = getbufvar(winbufnr(1), "&ft") ==# "NvimTree" ? 3 : 2
let s:wins = tabpagewinnr(tabpagenr(), "$")

" Open the fugitive buffer in a vertical split when there is space.
if s:wins <= s:limit && winwidth(0) >= 140
  wincmd L
  nmap <buffer> gh g?
else
  " For horizontal position, open the help window in the vertical split.
  nnoremap <buffer> gh :<C-U>vertical help fugitive-map<CR>
endif

nmap <buffer><nowait> q gq
