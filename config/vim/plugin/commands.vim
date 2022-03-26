" This always happens!
" command! W :w
" command! Q :q
" command! Qa :qa
" command! Wa :wa
" command! Wqa :wqa
" command! WQa :wqa


" Ref: https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
command! Hi
      \ :echo "hi<" . synIDattr(synID(line("."), col("."), 1), "name") . '> trans<'
      \ . synIDattr(synID(line("."), col("."), 0), "name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name") . ">"
