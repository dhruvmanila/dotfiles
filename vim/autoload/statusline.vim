let g:statusline_modes = {
      \ 'n': 'NORMAL',
      \ 'i': 'INSERT',
      \ 'R': 'REPLACE',
      \ 'v': 'VISUAL',
      \ 'V': 'V-LINE',
      \ "\<c-v>": 'V-BLOCK',
      \ 's': 'SELECT',
      \ 'S': 'S-LINE',
      \ "\<c-s>": 'S-BLOCK',
      \ 'c': 'COMMAND',
      \ 't': 'TERMINAL',
      \ 'r': 'PROMPT',
      \ '!': 'SHELL'
      \ }

function! statusline#mode() abort
  return get(g:statusline_modes, mode())
endfunction

function! statusline#gitbranch() abort
  if exists('g:loaded_fugitive')
    let l:branch = FugitiveHead()
    if !empty(l:branch)
      return ' [' . l:branch . ']'
    endif
  endif
  return ''
endfunction
