" " Ref: https://github.com/itchyny/lightline.vim
" " NOTE:
" " - Lightline configuration should come before color scheme configuration
" " - Lightline colorscheme is set using color_scheme_config
" "
" " TODO: Remove lightline and use the builtin statusline or when moved to
" " neovim, use express_line by tj
"
" let g:lightline = {}
"
" let g:lightline.active = {
"       \ 'left': [
"       \   ['mode', 'paste'],
"       \   ['git_status'],
"       \   ['filepath']
"       \ ],
"       \ 'right': [
"       \   ['linter_errors', 'linter_warnings', 'linter_infos', 'lineinfo'],
"       \   ['filetype', 'fileformat'],
"       \   ['coc_status'],
"       \ ]
"       \ }
"
" let g:lightline.inactive = {
"       \ 'left': [ ['absolutepath'] ],
"       \ 'right': [ ['lineinfo'] ]
"       \ }
"
" let g:lightline.tabline = {
"       \ 'left': [['vim_logo', 'tabs']],
"       \ }
"
" let g:lightline.component = {
"       \ 'vim_logo': "\ue7c5",
"       \ 'lineinfo': '%2p%%  %2l:%-2c%<',
"       \ 'filepath': "%f%{&modified ? ' [+]' : ''}%{&readonly ? ' [RO]' : ''}",
"       \ 'filetype': "%{winwidth(0) > 70 ? (&ft !=# '' ? &ft : 'no ft') : ''}",
"       \ 'fileformat': "%{winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) . '['.&ff.']' : ''}",
"       \ 'git_status': "%{LightlineGitStatus()}",
"       \ 'coc_status': "%{get(g:, 'coc_status', '')}",
"       \ }
"
" let g:lightline.component_expand = {
"       \ 'linter_infos': 'lightline#ale#infos',
"       \ 'linter_warnings': 'lightline#ale#warnings',
"       \ 'linter_errors': 'lightline#ale#errors',
"       \ }
"
" let g:lightline.component_type = {
"       \ 'linter_infos': 'right',
"       \ 'linter_warnings': 'warning',
"       \ 'linter_errors': 'error',
"       \ }
"
" " Ale error indicator for lightline
" let g:lightline#ale#indicator_infos = "i"
" let g:lightline#ale#indicator_warnings = "!"
" let g:lightline#ale#indicator_errors = "✘"
"
" function! LightlineGitStatus()
"   if exists('g:loaded_fugitive')
"     let l:branch = FugitiveHead()
"     if l:branch !=# ''
"       return ' ' . l:branch
"     endif
"     return ''
"   endif
" endfunction
"
" augroup lightline_update
"   autocmd!
"   autocmd CmdlineEnter,CmdwinEnter * call lightline#update() | redraw
" augroup END
