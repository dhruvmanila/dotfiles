-- Ref:
-- sonokai: https://github.com/sainnhe/sonokai
-- gruvbox-material: https://github.com/sainnhe/gruvbox-material
-- gruvbox (lua version): https://github.com/npxbr/gruvbox.nvim

local g = vim.g
local cmd = vim.cmd

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
-- g.gruvbox_material_visual = 'reverse'

-- Generates after/ftplugin/*.vim files for lazy loading
g.gruvbox_material_better_performance = 1

cmd('colorscheme gruvbox-material')

-- nvim-nonicons loads the plugin, thus setting the highlights for the icons.
-- But, then we are setting the colorscheme which will reset all the
-- highlights. This is the reason we need to call it after setting up the
-- colorscheme.
require('nvim-web-devicons').setup()

local highlight = vim.fn['gruvbox_material#highlight']
local palette = vim.fn['gruvbox_material#get_palette'](
  g.gruvbox_material_background, g.gruvbox_material_palette
)

highlight('PmenuSel', palette.bg3, palette.blue, 'bold')
highlight('HintFloat', palette.aqua, palette.bg3)

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
cmd('highlight! link LspDiagnosticsVirtualTextError Red')
cmd('highlight! link LspDiagnosticsVirtualTextWarning Yellow')
cmd('highlight! link LspDiagnosticsVirtualTextInformation Blue')
cmd('highlight! link LspDiagnosticsVirtualTextHint Aqua')
