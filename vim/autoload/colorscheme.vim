" Set to the given color scheme using all the commands listed in
" 'color_scheme_config', if it exists.
" Default: g:vim_colors_name
function! colorscheme#vim(name = g:vim_colors_name) abort
  let g:vim_colors_name = a:name
  for l:item in g:color_scheme_config[a:name]
    execute l:item
  endfor
endfunction


" Set the lightline color scheme
function! colorscheme#lightline(name) abort
  let l:filepath = globpath(
        \ &runtimepath,
        \ join(['autoload/lightline/colorscheme/', a:name, '.vim'], ''), 0, 1)[0]
  execute join(['source', l:filepath], ' ')
  let g:lightline.colorscheme = a:name
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction


" Update the tmuxline config according to the current theme and store it under
" the assets directory and also override the current tmux theme file.
function! colorscheme#tmux(name, lightline_color = "lightline") abort
  " Do not run the command on vim startup but only on subsequent calls to
  " colorscheme#vim function.
  if exists('g:loaded_vim_colors')
    execute 'Tmuxline ' . a:lightline_color
    execute 'TmuxlineSnapshot! ~/dotfiles/tmux/tmuxline/assets/' . a:name . '.tmux.conf'
    TmuxlineSnapshot! ~/dotfiles/tmux/tmuxline/current.tmux.conf
    silent !tmux source-file ~/dotfiles/tmux/tmux.conf
  endif
endfunction
