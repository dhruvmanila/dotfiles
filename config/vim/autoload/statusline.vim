function! statusline#gitbranch() abort
  if !exists('g:loaded_fugitive') | return '' | endif
  let l:branch = FugitiveHead()
  if !empty(l:branch)
    return ' [' . l:branch . ']'
  endif
  return ''
endfunction

function! statusline#ale() abort
  if !exists('g:loaded_ale') | return '' | endif
  let l:counts = ale#statusline#Count(bufnr())
  let l:infos = l:counts.info
  let l:warnings = l:counts.warning + l:counts.style_warning
  let l:errors = l:counts.error + l:counts.style_error
  let l:msgs = []
  if l:infos != 0
    call add(l:msgs, 'I: ' . l:infos)
  endif
  if l:warnings != 0
    call add(l:msgs, 'W: ' . l:warnings)
  endif
  if l:errors != 0
    call add(l:msgs, 'E: ' . l:errors)
  endif
  if !empty(l:msgs)
    return '[' . join(msgs, ' ') . ']'
  endif
  return ''
endfunction

function! statusline#coc() abort
  if !exists('g:did_coc_loaded') | return '' | endif
  return coc#status()
endfunction
