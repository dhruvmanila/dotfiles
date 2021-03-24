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
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <Leader>; :Buffers<CR>

" F mappings
nnoremap <silent> <Leader>fh :Helptags<CR>
nnoremap <silent> <Leader>fl :BLines<CR>
nnoremap <silent> <Leader>fm :Maps<CR>
nnoremap <silent> <Leader>fd :Files ~/dotfiles/<CR>
nnoremap <silent> <Leader>fa :AFiles<CR>
nnoremap <silent> <Leader>fc :Commands<CR>

nnoremap <silent> <Leader>gc :Commits<CR>
" To match with telescope.builtin.live_grep key binding
nnoremap <silent> <Leader>gr :Rg<CR>

" Enhanced with fzf
nnoremap <silent> q: :History:<CR>
nnoremap <silent> q/ :History/<CR>
