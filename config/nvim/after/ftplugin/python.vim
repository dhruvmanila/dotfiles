" Run with :make
setlocal makeprg=python3\ %

" Format with 'gq'
setlocal formatprg=black\ -q\ -

function! s:search_python_docs(word) abort
  let l:baseurl = 'https://docs.python.org/3.9/search.html?q=%s'
  call external#browser(printf(l:baseurl, a:word))
endfunction

nnoremap <silent><buffer> gk :call <SID>search_python_docs(expand('<cWORD>'))<CR>
