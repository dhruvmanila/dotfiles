" Ref:
"   vim-monokai-tasty: https://github.com/patstockwell/vim-monokai-tasty
"   sonokai: https://github.com/sainnhe/sonokai
"   gruvbox-material: https://github.com/sainnhe/gruvbox-material

" Color scheme configuration list
"
" Keys: colorscheme name
" Values: All the commands which will be ran by the function colorscheme#vim
let g:color_scheme_config = {}

let g:color_scheme_config['vim-monokai-tasty'] = [
      \ 'set background=dark',
      \ 'let g:vim_monokai_tasty_italic = 0',
      \ 'colorscheme vim-monokai-tasty',
      \ 'call colorscheme#tmux("monokai-tasty")',
      \ ]

" Sonokai Style: 'default', 'atlantis', 'andromeda', 'shusia', 'maia'
let g:color_scheme_config['sonokai'] = [
      \ 'set background=dark',
      \ "let g:sonokai_style = 'shusia'",
      \ 'let g:sonokai_enable_italic = 1',
      \ 'let g:sonokai_disable_italic_comment =  1',
      \ 'let g:sonokai_better_performance = 1',
      \ "let g:sonokai_sign_column_background = 'none'",
      \ 'colorscheme sonokai',
      \ 'call colorscheme#tmux("sonokai-shusia", "lightline_insert")',
      \ ]

" palette: 'original', 'mix', 'material'
" background: 'hard', 'medium', 'soft'
let g:color_scheme_config['gruvbox-material'] = [
      \ 'set background=dark',
      \ "let g:gruvbox_material_palette = 'original'",
      \ "let g:gruvbox_material_background = 'medium'",
      \ 'let g:gruvbox_material_enable_italic = 1',
      \ 'let g:gruvbox_material_disable_italic_comment = 1',
      \ "let g:gruvbox_material_sign_column_background = 'none'",
      \ 'let g:gruvbox_material_better_performance = 1',
      \ 'colorscheme gruvbox-material',
      \ 'highlight! link smlKeyChar Red',
      \ 'highlight! link CursorLineNr MoreMsg',
      \ 'call colorscheme#lightline("gruvbox_material")',
      \ ]
" \ 'highlight! link StatusLine TabLineSel',
" \ 'call colorscheme#tmux("gruvbox-material")',
