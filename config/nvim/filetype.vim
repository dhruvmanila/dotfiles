" Why using this file instead of `ftdetect/`? {{{
"
" Because it's sourced BEFORE `$VIMRUNTIME/filetype.vim`. Our autocmds will
" match first, and because the other autocmds use `:setfiletype`, they won't
" re-set 'filetype'.
"
" This way, we make sure that, for the files whose path match the patterns used
" in the following autocmds, our 'filetype' value has priority, and the filetype
" will be set only once (not twice).
"
" For more info about the syntax of this file, see `:help ftdetect`.
" }}}

if exists('did_load_filetypes')
    finish
endif

" `:setfiletype [FALLBACK] {filetype}`
"
" About the optional FALLBACK argument:
"
" When it's present, a later `:setfiletype` command will override `'filetype'`.
" This is to be used for filetype detections that are just a guess.
" `did_filetype()` will return false after this command.

augroup filetypedetect
  autocmd BufNewFile,BufRead Dockerfile*
        \ | if fnamemodify(expand('<amatch>'), ':e') != 'lua'
        \ |   setfiletype Dockerfile
        \ | endif

  " All files with an extension `.log` or ending with `_log`
  autocmd BufNewFile,BufRead *[_.]log setfiletype log

  autocmd BufNewFile,BufRead {Brew,Vagrant}file setfiletype ruby

  " We are using this filetype to set options in the terminal buffer.
  " See: ./after/ftplugin/terminal.lua
  autocmd TermOpen term://* setfiletype terminal
augroup END
