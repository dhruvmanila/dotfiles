" :sc -> :SClose
" :sd -> :SDelete
" :sr -> :SRename
" :ss -> :SSoad
cnoreabbrev <expr> sc getcmdtype() == ':' && getcmdpos() == 3 ? 'SClose' : 'sc'
cnoreabbrev <expr> sd getcmdtype() == ':' && getcmdpos() == 3 ? 'SDelete' : 'sd'
cnoreabbrev <expr> sr getcmdtype() == ':' && getcmdpos() == 3 ? 'SRename' : 'sr'
cnoreabbrev <expr> ss getcmdtype() == ':' && getcmdpos() == 3 ? 'SSave' : 'ss'
