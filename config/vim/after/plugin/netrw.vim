" Key:
" i - change views (3: tree view)
" u - go up a recent dir
" U - go down a recent dir
" - - go up a dir

let g:netrw_banner = 0

" <CR> will open file by:
" 0 - same window
" 1 - horizontal split
" 2 - vertical split
" 3 - in a new tab
let g:netrw_browse_split = 0

" Open preview window in a vertical split (0 - horizontal)
let g:netrw_preview = 1

" Number describes the % of the current buffer's window
let g:netrw_winsize = 25

" Use rm instead of the default rmdir as the later only removes empty directory
let g:netrw_localrmdir = 'rm -r'


function! s:netrw_mapping()
  nmap <buffer> ? <F1>
  " Easy moving up and down the tree
  nmap <buffer> h -
  nmap <buffer> l <CR>
  " Create a new file
  nmap <buffer> f %
  " Toggle dotfiles
  nmap <buffer> . gh
  " Close the preview window
  nmap <buffer> P <C-w>z
  " Open the file and close netrw
  " nmap <buffer> L <CR>:Lexplore<CR>
  " <C-l> is refresh in netrw
  nmap <buffer> r :e .<CR>
  nmap <buffer> <C-l> <C-w>l
endfunction


augroup netrw
  autocmd!
  autocmd FileType netrw setlocal signcolumn=no
  autocmd FileType netrw call <SID>netrw_mapping()
  " autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'netrw') | q | endif
augroup END

" Thinking of using the plain :Explore
" Another idea: either open the netrw explorer directly when we split using
" <leader>- or <leader>\|, or not and use a shortcut like <leader>n to open
" the explorer.
nmap <silent> <Leader>n :Explore<CR>
" nmap <Leader>n :Lexplore<CR>
" nmap <Leader>f :Lexplore %:p:h<CR>
