" Set all the open windows to equal width.
" `wincmd =` changes the height as well, we will extract the height
" changes from `winrestcmd` and execute it.
" Use: NERDTree
function! functions#set_windows_to_equal_width()
  let l:restoreCommands = split(winrestcmd(), '|')
  let l:heightCommands = filter(
        \ l:restoreCommands,
        \ { idx, cmd -> cmd =~# '^:\dresize' }
        \ )
  wincmd =
  execute join(l:heightCommands, '|')
endfunction
