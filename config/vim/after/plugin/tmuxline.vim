" Ref: https://github.com/edkolev/tmuxline.vim

let g:tmuxline_status_justify = 'left'
let g:tmuxline_powerline_separators = 0

let g:tmuxline_preset = {
      \ 'a'    : '#S',
      \ 'win'  : [ '#I: #W #F' ],
      \ 'cwin' : [ '#I: #W #F' ],
      \ 'x'    : '#(~/dotfiles/tmux/scripts/music.sh) '
      \          . '#{?client_prefix,#[fg=black]#[bg=yellow] PREFIX,'
      \          . '#{?rectangle_toggle,#[fg=black]#[bg=blue] C-BLOCK,'
      \          . '#{?pane_in_mode,#[fg=black]#[bg=blue] COPY,'
      \          . '#{?window_zoomed_flag,#[fg=black]#[bg=green] ZOOMED,}}}}',
      \ 'y'    : [ '%a %d %b', '%H:%M', '#(~/dotfiles/tmux/scripts/battery.sh)' ],
      \ 'z'    : '#H'
      \ }
