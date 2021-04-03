setlocal signcolumn=yes:1
setlocal nonumber
setlocal norelativenumber
setlocal nolist

" Recursive key bindings
nmap <silent><buffer><nowait> q gq
nmap <silent><buffer> gh g?
nmap <silent><buffer> h -
nmap <silent><buffer> l i

" Quick switching the context
nnoremap <silent><buffer> ~ :Dirvish $HOME<CR>
nnoremap <silent><buffer> ` :Dirvish /<CR>

nnoremap <silent><buffer> v :call dirvish#open('vsplit', 0)<CR>:wincmd p<CR>
xnoremap <silent><buffer> v :call dirvish#open('vsplit', 0)<CR>:wincmd p<CR>

" Hide dotfiles. Press `R` to "toggle" (reload).
nnoremap <silent><buffer> .
      \ :silent keeppatterns g@\v/\.[^\/]+/?$@d _<CR>
      \ :setlocal conceallevel=3<CR> 

if exists('b:dovish_ftplugin')
  nmap <silent><buffer> nf <Plug>(dovish_create_file)
  nmap <silent><buffer> nd <Plug>(dovish_create_directory)
  nmap <silent><buffer> dd <Plug>(dovish_delete)
  nmap <silent><buffer> r  <Plug>(dovish_rename)
  nmap <silent><buffer> yy <Plug>(dovish_yank)
  xmap <silent><buffer> y  <Plug>(dovish_yank)
  nmap <silent><buffer> c  <Plug>(dovish_copy)
  nmap <silent><buffer> m  <Plug>(dovish_move)
endif

" call dirvish#add_icon_fn(
"       \ {p -> luaeval("require('nvim-web-devicons').get_icon(vim.fn.fnamemodify(_A, ':t'), vim.fn.fnamemodify(_A, ':e'), {default = true})", p)}
"       \ )
