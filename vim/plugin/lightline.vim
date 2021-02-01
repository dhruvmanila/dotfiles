let g:lightline = {
      \ 'colorscheme': 'custom_monokai_tasty',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['gitbranch', 'readonly'],
      \     ['cocstatus', 'filename']
      \   ],
      \   'right': [
      \     ['linter_errors', 'linter_warnings', 'linter_infos', 'lineinfo'],
      \     ['filetype'],
      \     ['fileformat', 'fileencoding'],
      \   ]
      \ },
      \ 'inactive': {
      \   'right': [
      \     ['lineinfo']
      \   ]
      \ },
      \ 'component': {
      \   'lineinfo': '%3p%%  %3l:%-2c%<',
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'gitbranch': 'LightlineGitBranch',
      \   'filename': 'LightlineFilename',
      \   'readonly': 'LightlineReadonly',
      \   'fileencoding': 'LightlineFileencoding',
      \   'filetype': 'LightlineFiletype',
      \   'fileformat': 'LightlineFileformat'
      \ },
      \ 'component_expand': {
      \   'linter_infos': 'lightline#ale#infos',
      \   'linter_warnings': 'lightline#ale#warnings',
      \   'linter_errors': 'lightline#ale#errors',
      \ },
      \ 'component_type': {
      \   'linter_infos': 'right',
      \   'linter_warnings': 'warning',
      \   'linter_errors': 'error',
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
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
