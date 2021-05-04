-- Ref:
-- sonokai: https://github.com/sainnhe/sonokai
-- gruvbox-material: https://github.com/sainnhe/gruvbox-material
-- gruvbox (lua version): https://github.com/npxbr/gruvbox.nvim
local g = vim.g
local highlight = require('core.utils').highlight

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

-- Don't do highlight clear
g.colors_name = 'gruvbox-material'

vim.cmd('colorscheme gruvbox-material')

local palette = vim.fn['gruvbox_material#get_palette'](
  g.gruvbox_material_background, g.gruvbox_material_palette
)

highlight('PmenuSel', {guifg = palette.bg3[1], guibg = palette.blue[1], gui = 'bold'})
highlight('HintFloat', {guifg = palette.aqua[1], guibg = palette.bg3[1]})
highlight('GreyItalic', {guifg = palette.grey1[1], gui = 'italic'})

-- Current line number
highlight('CursorLineNr', {force = true, link = 'MoreMsg'})

-- Telescope.nvim
highlight('TelescopeSelection', {force = true, link = 'Visual'})
highlight('TelescopeSelectionCaret', {force = true, link = 'Yellow'})
highlight('TelescopeMatching', {force = true, link = 'Blue'})
-- highlight('TelescopeBorder', {force = true, link = 'Normal'})

-- Treesitter
highlight('TSFunction', {force = true, link = 'Function'})
highlight('TSParameter', {force = true, link = 'Blue'})
highlight('TSProperty', {force = true, link = 'Blue'})
highlight('TSField', {force = true, link = 'Blue'})

-- Lsp
highlight('VirtualTextHint', {force = true, link = 'Aqua'})

-- Symbols outline
highlight('FocusedSymbol', {force = true, link = 'CurrentWord'})
