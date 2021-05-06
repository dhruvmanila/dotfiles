" " TODO: Update to lua once funcref support is added
" let s:icons = luaeval("require('core.icons').icons")

" function s:custom_startify_section()
"   let l:last_session = fnamemodify(resolve(startify#get_session_path() . '/__LAST__'), ':t')

"   let l:items = [
"     \ {'line': s:icons.pin.'  Last Session ('.l:last_session.')', 'cmd': 'SLoad __LAST__'},
"     \ {'line': s:icons.globe.'  Find Sessions', 'cmd': "lua require('plugin.telescope').startify_sessions()"},
"     \ {'line': s:icons.history.'  Recently Opened Files', 'cmd': 'Telescope oldfiles'},
"     \ {'line': s:icons.file.'  Find Files', 'cmd': "lua require('plugin.telescope').find_files()"},
"     \ {'line': s:icons.stopwatch.'  StartupTime', 'cmd': 'StartupTime'},
"     \ ]

"   let g:startify_center = max(map(copy(l:items), "strwidth(v:val.line)")) + 5
"   return l:items
" endfunction

" " To set the `g:startify_center` variable
" call s:custom_startify_section()

" let g:startify_lists = [
"   \ {
"   \   'type': function('s:custom_startify_section'),
"   \   'indices': ['l', 's', 'h', 'f', 'p']
"   \ },
"   \ ]
