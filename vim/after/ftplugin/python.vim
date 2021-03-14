setlocal tabstop=4
setlocal shiftwidth=4

" Default is 80
setlocal colorcolumn=88

" function! s:search_python_docs(word) abort
"   let l:baseurl = 'https://docs.python.org/3.9/search.html?q=%s'
"   call external#browser(printf(l:baseurl, a:word))
" endfunction
"
" nnoremap <silent> gk :call <SID>search_python_docs(expand('<cWORD>'))<CR>
