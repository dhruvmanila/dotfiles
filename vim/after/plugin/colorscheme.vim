" NOTES:
"
" vim/vimrc
"   contains the global variable g:vim_colors_name which is used to set the
"   colorscheme for vim, lightline and tmux.
"
" vim/plugin/colorscheme.vim
"   contains the color scheme config dictionary where the key is the name of
"   the color scheme and the values are list of commands to be run like
"   setting color scheme options, colorscheme itself, lightline and tmux
"   colorscheme.
"
" vim/after/plugin/colorscheme.vim (this file)
"   contains the entry point to set the color scheme on vim startup
"
"
" On vim startup, set the colorscheme for vim and lightline (tmux already
" sourced .tmux.conf)
"
" Use the function colorscheme#vim to change colorscheme for vim, lightline
" and tmux on the fly.
"
" g:loaded_vim_colors flag is used by colorscheme#tmux to check whether we
" were called on vim startup or manually by the user.

try
  if !exists('g:colors_name')
    call colorscheme#vim()
    let g:loaded_vim_colors = 1
  endif
catch /.*/
  colorscheme desert
  set nocursorline
  set notermguicolors
endtry
