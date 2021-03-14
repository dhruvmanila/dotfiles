" Ref: https://github.com/junegunn/fzf.vim

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

" Disable preview window by default. Toggle using ctrl-p
let g:fzf_preview_window = ['right:50%:hidden', 'ctrl-p']

" All files
command! -nargs=? -complete=dir AFiles
      \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
      \   'source': 'fd --type f --hidden --follow --exclude .git --no-ignore . '.expand(<q-args>)
      \ })))

" WIP
" Most used mappings
nnoremap <C-p> :Files<CR>
nnoremap <Leader><Enter> :Buffers<CR>

" F mappings
nnoremap <Leader>fh :Helptags<CR>
nnoremap <Leader>fl :BLines<CR>
nnoremap <Leader>fm :Maps<CR>
nnoremap <Leader>fd :Files ~/dotfiles/<CR>
nnoremap <Leader>fa :AFiles<CR>

nnoremap <Leader>gc :Commits<CR>
nnoremap <Leader>rg :Rg<CR>

" Enhanced with fzf
nnoremap q: :History:<CR>
nnoremap q/ :History/<CR>
