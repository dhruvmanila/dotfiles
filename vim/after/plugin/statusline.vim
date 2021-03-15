" Initialize the statusline
set statusline=

" Mode of the current buffer
set statusline+=[%{statusline#mode()}]

" Git branch
set statusline+=%{statusline#gitbranch()}

" File path as typed or relative to current directory
set statusline+=\ %f

" Modified flag
set statusline+=\ %m

" Readonly flag
set statusline+=\ %r

" Preview window flag
set statusline+=\ %w

" Quickfix / Location List or empty
set statusline+=\ %q

" Separation point between left and right aligned items
set statusline+=%=

" Filetype
set statusline+=\ %y

" Line and column number
set statusline+=\ [%l:%c]

" Percentage like the one described for 'ruler'. Always 3 in length.
set statusline+=\ [%P]
