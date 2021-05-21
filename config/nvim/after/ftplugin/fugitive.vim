setlocal nonumber
setlocal norelativenumber
setlocal nolist

" Shift the fugitive window to a vertical split
if len(nvim_tabpage_list_wins(0)) <= 2
  wincmd L
  nnoremap <buffer> gh :<C-U>help fugitive-map<CR>
else
  " For horizontal position, open the help window in the vertical split.
  nnoremap <buffer> gh :<C-U>vertical help fugitive-map<CR>
endif

nmap <nowait> q gq
