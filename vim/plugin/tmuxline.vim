let g:tmuxline_status_justify = 'left'

let g:tmuxline_preset = {
      \ 'a'    : '#S',
      \ 'win'  : [ '#I', '#W' ],
      \ 'cwin' : [ '#I', '#W', '#F' ],
      \ 'y'    : [ '%a %d %b', '%H:%M', '#(~/dotfiles/tmux/scripts/battery.sh)' ],
      \ 'z'    : '#H #{prefix_highlight}'
      \ }

let g:tmuxline_separators = {
      \ 'left' : "\ue0b8",
      \ 'left_alt': "\ue0b9",
      \ 'right' : "\ue0ba",
      \ 'right_alt' : "\ue0bb",
      \ 'space' : ' '
      \ }
