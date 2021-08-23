" There is no reliable way of doing abbreviations in lua except for using a
" `vim.cmd` block which is just ugly.

" Packer commands (`wbthomason/packer.nvim`)
cnoreabbrev <expr> pc getcmdtype() == ':' && getcmdpos() == 3 ? 'PackerClean' : 'pc'
cnoreabbrev <expr> po getcmdtype() == ':' && getcmdpos() == 3 ? 'PackerCompile' : 'pl'
cnoreabbrev <expr> pi getcmdtype() == ':' && getcmdpos() == 3 ? 'PackerInstall' : 'pi'
cnoreabbrev <expr> ps getcmdtype() == ':' && getcmdpos() == 3 ? 'PackerSync' : 'ps'
cnoreabbrev <expr> pu getcmdtype() == ':' && getcmdpos() == 3 ? 'PackerUpdate' : 'pu'

" :so -> :source %
cnoreabbrev <expr> so getcmdtype() == ':' && getcmdpos() == 3 ? 'source %' : 'so'

" For better readability (`tpope/vim-scriptease`)
cnoreabbrev <expr> mes getcmdtype() == ':' && getcmdpos() == 4 ? 'Message' : 'mes'
cnoreabbrev <expr> veb getcmdtype() == ':' && getcmdpos() == 4 ? 'Verbose' : 'veb'

inoreabbrev ie i.e.,
inoreabbrev eg e.g.,
