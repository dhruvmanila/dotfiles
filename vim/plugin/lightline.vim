let g:lightline = {}

" Set in plugin/colors.vim
let g:lightline.colorscheme = g:lightline_color_scheme

" Ref: https://www.nerdfonts.com/cheat-sheet
" \ue0b0 =     \ue0b8 =     \ue0bc = 
" \ue0b1 =     \ue0b9 =     \ue0be = 
" \ue0b2 =     \ue0ba = 
" \ue0b3 =     \ue0bb = 
let g:lightline.separator = { 'left': "\ue0b8", 'right': "\ue0ba" }
let g:lightline.subseparator = { 'left': "\ue0b9", 'right': "\ue0bb" }
let g:lightline.tabline_separator = { 'left': "\ue0bc", 'right': "\ue0be" }
let g:lightline.tabline_subseparator = { 'left': "\ue0bb", 'right': "\ue0b9" }

let g:lightline.active = {
      \ 'left': [
      \   ['mode', 'paste'],
      \   ['readonly', 'filename', 'fileformat', 'filetype'],
      \ ],
      \ 'right': [
      \   ['linter_errors', 'linter_warnings', 'linter_infos', 'lineinfo'],
      \   [],
      \   ['coc_status'],
      \ ]
      \ }

let g:lightline.inactive = {
      \ 'left': [['filename', 'fileformat', 'filetype']],
      \ 'right': [['lineinfo']]
      \ }

let g:lightline.tabline = {
      \ 'left': [['vim_logo', 'tabs']],
      \ 'right': [['gitbranch']]
      \ }

let g:lightline.tab = {
      \ 'active': [ 'tabnum', 'filename', 'modified' ],
      \ 'inactive': [ 'tabnum', 'filename', 'modified' ] }

let g:lightline.component = {
      \ 'lineinfo': '%2p%%  %2l:%-2c%<',
      \ 'vim_logo': "\ue7c5",
      \ 'readonly': '%{&readonly?"":""}',
      \ }

let g:lightline.component_function = {
      \ 'coc_status': 'CocStatus',
      \ 'gitbranch': 'LightlineGitBranch',
      \ 'filename': 'LightlineFilename',
      \ 'filetype': 'LightlineFiletype',
      \ 'fileformat': 'LightlineFileformat'
      \ }

let g:lightline.tab_component_function = {
      \ 'tabnum': 'LightlineTabnum',
      \ }

let g:lightline.component_expand = {
      \ 'linter_infos': 'lightline#ale#infos',
      \ 'linter_warnings': 'lightline#ale#warnings',
      \ 'linter_errors': 'lightline#ale#errors',
      \ }

let g:lightline.component_type = {
      \ 'linter_infos': 'right',
      \ 'linter_warnings': 'warning',
      \ 'linter_errors': 'error',
      \ }


" Ale error indicator for lightline
let g:lightline#ale#indicator_infos = "i"
let g:lightline#ale#indicator_warnings = "!"
let g:lightline#ale#indicator_errors = "✘"

" Use autocmd to force lightline update.
augroup coc_lightline_update
  autocmd!
  autocmd User CocStatusChange call lightline#update()
  autocmd User CocDiagnosticChange call lightline#update()
augroup END

function! CocStatus()
  return get(g:, 'coc_status', '')
endfunction

function! LightlineTabnum(num)
  return a:num . " \ue0bb"
endfunction

" For vim-fugitive plugin: let branch = FugitiveHead()
" For vim-gitbranch plugin: let branch = gitbranch#name()
function! LightlineGitBranch()
  let branch = FugitiveHead()
  return branch !=# '' ? ' '.branch : ''
endfunction

" Extra: Filename from the project root (git repository)
" https://github.com/itchyny/lightline.vim/issues/293
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) . '[' . &fileformat . ']' : ''
endfunction
