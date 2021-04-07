setlocal signcolumn=yes:1
setlocal nonumber
setlocal norelativenumber
setlocal nolist

" Recursive key bindings
nmap <silent><buffer><nowait> q <Plug>(dirvish_quit)
nmap <silent><buffer> h <Plug>(dirvish_up)

" Quick switching the context
nnoremap <silent><buffer> ~ :Dirvish $HOME<CR>
nnoremap <silent><buffer> ` :Dirvish /<CR>

" Better than the default g?
nnoremap <silent><buffer> gh :help dirvish-mappings<CR>

" Opening files/directories
nnoremap <silent><buffer> l :call dirvish#open('edit', 0)<CR>
nnoremap <silent><buffer> s :call dirvish#open('split', 1)<CR>
xnoremap <silent><buffer> s :call dirvish#open('split', 1)<CR>
nnoremap <silent><buffer> v :call dirvish#open('vsplit', 1)<CR>
xnoremap <silent><buffer> v :call dirvish#open('vsplit', 1)<CR>

" 'T' will open in new tab in the background
nnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>
xnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>
nnoremap <silent><buffer> T :call dirvish#open('tabedit', 1)<CR>
xnoremap <silent><buffer> T :call dirvish#open('tabedit', 1)<CR>

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
