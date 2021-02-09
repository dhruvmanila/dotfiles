" If you don't know what the name of a particular hightlight is, you can use `What`.
" It will print out the syntax group that the cursor is currently above.
" Ref: https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
command! What
      \ echo "hi<" . synIDattr(synID(line("."), col("."), 1), "name") . '> trans<'
      \ . synIDattr(synID(line("."), col("."), 0), "name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name") . ">"

" Vim can autodetect this based on $TERM (e.g. 'xterm-256color')
" but it can be set to force 256 colors.
" set t_Co=256

if exists('+termguicolors')
  set termguicolors
  " The commands below are needed for tmux + termguicolors
  " This is only necessary if you use "set termguicolors".
  let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
  let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
endif

" Color scheme
let g:vim_color_scheme = 'sonokai'

" Color scheme configuration list
let g:color_scheme_config = {}

let g:color_scheme_config['vim-monokai-tasty'] = [
      \ 'let g:vim_monokai_tasty_italic = 0',
      \ 'colorscheme vim-monokai-tasty',
      \ "let g:lightline_color_scheme = 'custom_monokai_tasty'",
      \ ]

" Sonokai Style: 'default', 'atlantis', 'andromeda', 'shusia', 'maia'
let g:color_scheme_config['sonokai'] = [
      \ "let g:sonokai_style = 'shusia'",
      \ 'let g:sonokai_enable_italic = 1',
      \ 'let g:sonokai_disable_italic_comment =  1',
      \ 'let g:sonokai_better_performance = 1',
      \ 'colorscheme sonokai',
      \ "let g:lightline_color_scheme = 'sonokai'",
      \ ]

" Switch to the given color scheme using all the commands listed in
" 'color_scheme_config'
function! SwitchColorScheme(name)
  for l:item in g:color_scheme_config[a:name]
    execute l:item
  endfor
endfunction

" Set the color scheme if it exists, else default to built in
try
  call SwitchColorScheme(g:vim_color_scheme)
catch /.*/
  colorscheme desert
  set nocursorline
  finish
endtry

" Enable all syntax highlighting features
let g:python_highlight_all = 1
