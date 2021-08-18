" There is no reliable way of doing abbreviations in lua except for using a
" `vim.cmd` block which is just ugly.

" :so -> :source %
cnoreabbrev <expr> so getcmdtype() == ':' && getcmdpos() == 3 ? 'source %' : 'so'

" :mes -> :Message (`tpope/vim-scriptease`)
cnoreabbrev <expr> mes getcmdtype() == ':' && getcmdpos() == 4 ? 'Message' : 'mes'

inoreabbrev ie i.e.,
inoreabbrev eg e.g.,
