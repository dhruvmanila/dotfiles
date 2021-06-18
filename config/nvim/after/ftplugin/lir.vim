setlocal nonumber
setlocal norelativenumber
setlocal nolist

" Similarly in visual mode
xnoremap <buffer><silent> C :<C-u>lua require("plugin.lir").clipboard_action("copy", "v")<CR>
xnoremap <buffer><silent> X :<C-u>lua require("plugin.lir").clipboard_action("cut", "v")<CR>

nnoremap <buffer><silent> / :lua require("dm.plugin.telescope").lir_cd()<CR>
