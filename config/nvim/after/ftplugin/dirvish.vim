setlocal signcolumn=no
setlocal nonumber
setlocal norelativenumber

" Recursive key bindings
nmap <silent><buffer> ? g?
nmap <silent><buffer> q gq
nmap <silent><buffer> h -
nmap <silent><buffer> l i


if exists('b:dovish_ftplugin')
  nmap <silent><buffer> f <Plug>(dovish_create_file)
  nmap <silent><buffer> d <Plug>(dovish_create_directory)
  nmap <silent><buffer> D <Plug>(dovish_delete)
  nmap <silent><buffer> r <Plug>(dovish_rename)
  nmap <silent><buffer> yy <Plug>(dovish_yank)
  xmap <silent><buffer> y <Plug>(dovish_yank)
  nmap <silent><buffer> c <Plug>(dovish_copy)
  nmap <silent><buffer> m <Plug>(dovish_move)
endif

" call dirvish#add_icon_fn(
"       \ {p -> luaeval("require('nvim-web-devicons').get_icon(vim.fn.fnamemodify(_A, ':t'), vim.fn.fnamemodify(_A, ':e'), {default = true})", p)}
"       \ )
