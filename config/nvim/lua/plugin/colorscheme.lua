-- Ref:
-- sonokai: https://github.com/sainnhe/sonokai
-- gruvbox-material: https://github.com/sainnhe/gruvbox-material
-- gruvbox (lua version): https://github.com/npxbr/gruvbox.nvim

local g = vim.g
local cmd = vim.cmd

vim.o.background = 'dark'

-- palette: 'original', 'mix', 'material'
g.gruvbox_material_palette = 'mix'

-- background: 'hard', 'medium', 'soft'
g.gruvbox_material_background = 'medium'

g.gruvbox_material_enable_bold = 1
g.gruvbox_material_enable_italic = 1
g.gruvbox_material_disable_italic_comment = 1
g.gruvbox_material_transparent_background = 0
g.gruvbox_material_menu_selection_background = 'blue'
g.gruvbox_material_sign_column_background = 'none'

-- Generates after/ftplugin/*.vim files for lazy loading
g.gruvbox_material_better_performance = 1

cmd('colorscheme gruvbox-material')

-- Second arg is a bool to determine whether the output should be returned or not.
vim.api.nvim_exec(
[[
let palette = gruvbox_material#get_palette(g:gruvbox_material_background, g:gruvbox_material_palette)

call gruvbox_material#highlight('PmenuSel', palette.bg3, palette.blue, 'bold')
]],
false
)

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



-- vim.o.background = 'dark'
-- g.gruvbox_bold = true
-- g.gruvbox_italic = false
-- g.gruvbox_italicize_comments = false
-- g.gruvbox_invert_selection = false
-- g.gruvbox_contrast_dark = 'medium'
-- -- g.gruvbox_hls_cursor = 'bright_red'  -- default: 'orange'
-- -- g.gruvbox_sign_column = 'dark0'  -- TODO: Not present in gruvbox.nvim
-- -- g.gruvbox_transparent_bg = true 
-- cmd('colorscheme gruvbox')
-- -- g.gruvbox_italicize_strings = true
