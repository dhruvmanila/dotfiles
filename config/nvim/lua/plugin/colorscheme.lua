-- Ref:
-- sonokai: https://github.com/sainnhe/sonokai
-- gruvbox-material: https://github.com/sainnhe/gruvbox-material
-- gruvbox (lua version): https://github.com/npxbr/gruvbox.nvim
local g = vim.g
local cmd = vim.cmd
-- local highlight = require('core.utils').highlight

vim.o.background = 'dark'

-- palette: 'original', 'mix', 'material'
g.gruvbox_material_palette = 'original'

-- background: 'hard', 'medium', 'soft'
g.gruvbox_material_background = 'medium'

g.gruvbox_material_enable_bold = 1
g.gruvbox_material_enable_italic = 1
g.gruvbox_material_disable_italic_comment = 1
g.gruvbox_material_transparent_background = 0
g.gruvbox_material_menu_selection_background = 'blue'
g.gruvbox_material_sign_column_background = 'none'
g.gruvbox_material_diagnostic_virtual_text = 'colored'
-- g.gruvbox_material_visual = 'reverse'

-- Generates after/ftplugin/*.vim files for lazy loading
g.gruvbox_material_better_performance = 1

cmd('colorscheme gruvbox-material')

-- Load the statusline and tabline
-- This should be called after setting the colorscheme as that resets the
-- higlights.
require('core.statusline')
require('core.tabline')

local highlight = vim.fn['gruvbox_material#highlight']
local palette = vim.fn['gruvbox_material#get_palette'](
  g.gruvbox_material_background, g.gruvbox_material_palette
)

highlight('PmenuSel', palette.bg3, palette.blue, 'bold')
highlight('HintFloat', palette.aqua, palette.bg3)

-- Tabline
cmd('highlight! TabLineSel  guifg=#ebdbb2 guibg=#282828 gui=bold,italic')
cmd('highlight! TabLine     guifg=#928374 guibg=#242424')
cmd('highlight! TabLineFill guifg=#928374 guibg=#1e1e1e')

cmd('highlight! link CursorLineNr MoreMsg')

-- Telescope.nvim
cmd('highlight! link TelescopeSelection CursorLine')
cmd('highlight! link TelescopeSelectionCaret Red')
cmd('highlight! link TelescopeMatching Blue')

-- Treesitter
cmd('highlight! link TSFunction Function')
cmd('highlight! link TSParameter Blue')
cmd('highlight! link TSProperty Blue')
cmd('highlight! link TSField Blue')

-- Lsp
cmd('highlight! link VirtualTextHint Aqua')
