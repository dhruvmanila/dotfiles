let g:tmuxline_status_justify = 'centre'

" Values represent: [ FG, BG, ATTR ]
"   FG ang BG are color codes
"   ATTR (optional) is a comma-delimited string of one or more of
"   bold, dim, underscore, etc.
if exists('g:vim_color_scheme') && g:vim_color_scheme ==# 'sonokai'
  let s:p = sonokai#get_palette(g:sonokai_style)
  let g:tmuxline_theme = {
      \ 'a'    : [ s:p.bg0[0], s:p.bg_green[0], 'bold' ],
      \ 'b'    : [ s:p.fg[0], s:p.bg4[0] ],
      \ 'c'    : [ s:p.fg[0], s:p.bg1[0] ],
      \ 'x'    : [ s:p.fg[0], s:p.bg1[0] ],
      \ 'y'    : [ s:p.fg[0], s:p.bg4[0] ],
      \ 'z'    : [ s:p.bg0[0], s:p.bg_green[0], 'bold' ],
      \ 'win'  : [ s:p.fg[0], s:p.bg4[0] ],
      \ 'cwin' : [ s:p.bg0[0], s:p.yellow[0] ],
      \ 'bg'   : [ s:p.fg[0], s:p.bg1[0] ],
      \ }
endif

let g:tmuxline_preset = {
      \ 'a'    : '#S',
      \ 'b'    : '%H:%M',
      \ 'win'  : [ '#I', '#W' ],
      \ 'cwin' : [ '#I', '#W', '#F' ],
      \ 'y'    : [ '%a %d %b', '#(~/dotfiles/tmux/scripts/battery.sh)' ],
      \ 'z'    : '#H #{prefix_highlight}'
      \ }

let g:tmuxline_separators = {
      \ 'left' : "\ue0b8",
      \ 'left_alt': "\ue0b9",
      \ 'right' : "\ue0ba",
      \ 'right_alt' : "\ue0bb",
      \ 'space' : ' '
      \ }
