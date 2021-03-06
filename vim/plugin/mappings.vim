" Ref: Get list of all custom mappings `:map [mapping]`
" n -> normal
" x -> visual
" v -> visual and select
" i -> insert

" Unbind some useless/annoying default key bindings.
" 'Q' in normal mode enters Ex mode. You almost never want this.
nnoremap <silent> Q <Cmd>qa<CR>

" Quick save
nnoremap <silent> <Leader>w <Cmd>w<CR>
nnoremap <silent> <Leader>q <Cmd>q<CR>
" nnoremap <Leader>wq :wq<CR>

" Move vertically by visual line
nnoremap j gj
nnoremap k gk

" Jump to start and end of line using the home row keys
map H ^
map L $

" Split with Leader (same as that of tmux)
nnoremap <Leader>- <Cmd>sp<CR>
nnoremap <Leader>\| <Cmd>vsp<CR>

" Buffer management
nnoremap ]<Leader> <Cmd>bnext<CR>
nnoremap [<Leader> <Cmd>bprev<CR>
nnoremap <Leader><BS> <Cmd>bdelete<CR>

" Fast switching between last and current file
nnoremap <Leader><Leader> <C-^>

" Movement in insert mode
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>l
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k

" Capital JK move code lines/blocks up & down (only in visual mode)
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv

" Visual indentation goes back to same selection
xnoremap < <gv
xnoremap > >gv

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Resize window with arrow keys as I hardly need them
nnoremap <Up> <C-w>5+
nnoremap <Down> <C-w>5-
nnoremap <Left> <C-w>5<
nnoremap <Right> <C-w>5>

" Easy moving through the command history
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>

" Replace the selection without overriding the paste register
xnoremap p "_dP

" Delete without overriding the paste register
nnoremap <Leader>d "_d
vnoremap <Leader>d "_d

" Prevent x from overriding what's in the clipboard.
nnoremap x "_x
nnoremap X "_X
vnoremap x "_x
vnoremap X "_X

" Yank the entire file and get the cursor back to its original place
nnoremap <Leader>Y ggyG<C-o><C-o>

" <tab> / <s-tab> | Circular windows navigation
" nnoremap <TAB>   <c-w>w
" nnoremap <S-TAB> <c-w>W

" Keep the cursor at
" (zt) &scrolloff lines away from the top
" (zz) the center
nnoremap * *zz
nnoremap # #zz
nnoremap n nzz
nnoremap N Nzz
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz

" Substitute the word on cursor globally
nnoremap <silent> <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" Mapping for the custom function
nnoremap <silent> <Leader>= :call functions#set_windows_to_equal_width()<CR>

" Set the terminal height to 2.5 of the current window and
" open it in the directory of the file
nmap <silent> <Leader>t
      \ :let $VIM_DIR=expand('%:p:h')<CR>
      \ :let &termwinsize = float2nr(winheight(0) / 2.5) . "x0"<CR>
      \ :terminal<CR>

" Open the terminal in a vertical split
nmap <silent> <Leader>vt
      \ :let $VIM_DIR=expand('%:p:h')<CR>
      \ :let &termwinsize = ''<CR>
      \ :vert terminal<CR>
