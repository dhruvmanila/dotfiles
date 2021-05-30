" Autosize quickfix to match its minimum content
" https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
function! s:adjust_height(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

nnoremap <silent><buffer><nowait> q :<C-u>quit<CR>

" Position the (global) quickfix window at the very bottom of the window
" (useful for making sure that it appears underneath splits).
"
" NOTE: Using a check here to make sure that window-specific location-lists
" aren't effected, as they use the same `FileType` as quickfix-lists.
"
" Taken from https://github.com/fatih/vim-go/issues/108#issuecomment-565131948.
if getwininfo(win_getid())[0].loclist != 1
  wincmd J
endif

" Some useful defaults
setlocal nonumber
setlocal norelativenumber
setlocal nowrap
setlocal colorcolumn=
setlocal nobuflisted  " quickfix buffers should not pop up when doing :bn or :bp

" Adjust the height of quickfix window to a minimum of 3 and maximum of 10.
call s:adjust_height(3, 10)
setlocal winfixheight
