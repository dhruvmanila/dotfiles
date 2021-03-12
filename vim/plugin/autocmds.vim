" Automatic reloading of .vimrc on save
" Nested is necessary to correctly reload lightline/airline
" augroup auto_reload_vimrc
"   autocmd!
"   autocmd BufWritePost .vimrc,vimrc nested source $MYVIMRC
" augroup END

" Highlight current line, but only in active window
augroup cursor_line_only_in_active_window
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setl cursorline
  autocmd WinLeave * setl nocursorline
augroup END

" Resize windows to equal width when vim resizes (&columns &lines changed)
" augroup equal_window_width_on_vim_resize
"   autocmd!
"   autocmd VimResized * call SetWindowsToEqualWidth()
" augroup END

" Triger `autoread` when files changes on disk and notify after file change
" https://unix.stackexchange.com/a/383044
augroup auto_reload_file_when_changed
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
    \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == ''
    \ | checktime
    \ | endif
  autocmd FileChangedShellPost *
    \ echohl WarningMsg
    \ | echo "File changed on disk. Buffer reloaded."
    \ | echohl None
augroup END
