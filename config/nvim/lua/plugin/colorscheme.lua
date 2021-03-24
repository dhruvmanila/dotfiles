-- Ref:
-- sonokai: https://github.com/sainnhe/sonokai
-- gruvbox-material: https://github.com/sainnhe/gruvbox-material
-- gruvbox (lua version): https://github.com/npxbr/gruvbox.nvim

local g = vim.g
local cmd = vim.cmd

-- palette: 'original', 'mix', 'material'
-- background: 'hard', 'medium', 'soft'
-- vim.o.background = 'dark'
-- vim.g.gruvbox_material_palette = 'original'
-- vim.g.gruvbox_material_background = 'medium'
-- vim.g.gruvbox_material_enable_bold = 1
-- vim.g.gruvbox_material_enable_italic = 1
-- vim.g.gruvbox_material_disable_italic_comment = 1
-- vim.g.gruvbox_material_sign_column_background = 'none'
-- vim.g.gruvbox_material_better_performance = 1
-- vim.cmd('colorscheme gruvbox-material')
-- vim.cmd('highlight! link CursorLineNr MoreMsg')
-- vim.cmd('highlight! link TSFunction Function')
-- vim.cmd('highlight! link TSParameter Blue')
-- vim.cmd('highlight! link TSProperty Blue')
-- vim.cmd('highlight! link TSField Blue')


vim.o.background = 'dark'
g.gruvbox_bold = true
g.gruvbox_italic = false
g.gruvbox_invert_selection = false
g.gruvbox_contrast_dark = 'medium'
-- g.gruvbox_hls_cursor = 'bright_red'  -- default: 'orange'
-- g.gruvbox_sign_column = 'dark0'  -- TODO: Not present in gruvbox.nvim
-- g.gruvbox_transparent_bg = true 
cmd('colorscheme gruvbox')
-- g.gruvbox_italicize_comments = false
-- g.gruvbox_italicize_strings = true
