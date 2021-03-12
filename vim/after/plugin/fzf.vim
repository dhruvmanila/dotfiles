" Ref: https://github.com/junegunn/fzf.vim

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }

" Disable preview window
let g:fzf_preview_window = []

" nnoremap <C-p> :Files<CR>
nnoremap <Leader>H :History<CR>
nnoremap <Leader>e :Files<CR>
nnoremap <Leader>h :Helptags<CR>
nnoremap <Leader>; :Buffers<CR>
nnoremap <Leader>d :Files ~/dotfiles/<CR>
