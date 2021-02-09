let g:lightline = {}

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
      \   ['gitbranch', 'readonly'],
      \   ['cocstatus', 'filename']
      \ ],
      \ 'right': [
      \   ['linter_errors', 'linter_warnings', 'linter_infos', 'lineinfo'],
      \   ['filetype'],
      \   ['fileformat', 'fileencoding'],
      \ ]
      \ }

let g:lightline.inactive = {'right': [['lineinfo']]}

let g:lightline.tabline = {
      \ 'left': [['vim_logo', 'tabs']],
      \ 'right': [['close']]
      \ }

let g:lightline.tab = {
      \ 'active': [ 'tabnum', 'filename', 'modified' ],
      \ 'inactive': [ 'tabnum', 'filename', 'modified' ] }

let g:lightline.component = {
      \ 'lineinfo': '%3p%%  %3l:%-2c%<',
      \ 'vim_logo': "\ue7c5"
      \ }

let g:lightline.component_function = {
      \ 'cocstatus': 'coc#status',
      \ 'gitbranch': 'LightlineGitBranch',
      \ 'filename': 'LightlineFilename',
      \ 'readonly': 'LightlineReadonly',
      \ 'fileencoding': 'LightlineFileencoding',
      \ 'filetype': 'LightlineFiletype',
      \ 'fileformat': 'LightlineFileformat'
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
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
augroup END

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

function! LightlineReadonly()
  return &readonly ? '' : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? (&fileformat !=# '' ? &fileformat : '') : ''
endfunction
