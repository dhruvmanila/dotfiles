" Initialize the statusline

function! s:statusline_init()
  let mod = "%{&modified ? ' [+]' : !&modifiable ? ' [-]' : ''}"
  let ro = "%{&readonly ? ' [RO]' : ''}"
  let ft = ' %y'
  let flgs = '%( %w %q%)'
  let br = '%{statusline#gitbranch()}'
  let sep = '%='
  let coc = ' %{statusline#coc()}'
  let ale = ' %{statusline#ale()}'
  let enc = " %{&fenc . '[' . &ff . ']'} "
  let pos = '| %-6(%l:%c%) %P '

  return '[%n] %f'.mod.ro.ft.flgs.br.sep.coc.ale.enc.pos
endfunction

" let &statusline = s:statusline_init()
