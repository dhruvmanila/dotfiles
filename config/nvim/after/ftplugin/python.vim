setlocal tabstop=4
setlocal shiftwidth=4

" Default is 80
" setlocal colorcolumn=88

" Format with 'gq'
setlocal formatprg=black\ -q\ -

function! s:search_python_docs(word) abort
  let l:baseurl = 'https://docs.python.org/3.9/search.html?q=%s'
  call external#browser(printf(l:baseurl, a:word))
endfunction

nnoremap <silent><buffer> gk :call <SID>search_python_docs(expand('<cWORD>'))<CR>

" if luaeval("_G.packer_plugins['nvim-lint'].loaded")
"   autocmd BufWritePost <buffer> lua require('lint').try_lint()
" endif
