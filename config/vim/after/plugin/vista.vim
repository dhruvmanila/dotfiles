" Use coc for now and then switch to nvim-lsp
let g:vista_default_executive = 'coc'

" Use fzf colors from the g:fzf_colors variable
let g:vista_keep_fzf_colors = 1

" Show the current position of the symbol in the floating window
let g:vista_echo_cursor_strategy = 'floating_win'

nnoremap <silent> <Leader>vv <Cmd>Vista!!<CR>
nnoremap <silent> <Leader>vd <Cmd>Vista finder fzf:coc<CR>

" Set custom mappings for the Vista buffer
function! s:vista_buffer_mappings()
  " Use / in the Vista buffer to search using fzf
  nnoremap <buffer> <silent> / :<C-u>call vista#finder#fzf#Run()<CR>
endfunction

augroup vista_custom
  autocmd!
  autocmd FileType vista,vista_kind call <SID>vista_buffer_mappings()
augroup END
