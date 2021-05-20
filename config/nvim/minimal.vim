set nocompatible hidden laststatus=2
map Q <nop>

" Download the plugin manager
if !filereadable('/tmp/plug.vim')
  silent !curl -fsSLo /tmp/plug.vim
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

source /tmp/plug.vim

call plug#begin('/tmp/plugged')
" Plugins to test

call plug#end()

autocmd VimEnter * PlugClean! | PlugUpdate --sync | close

" Load the plugins (packadd <plugin_name>)


" For lua only plugins
lua << EOF

EOF
