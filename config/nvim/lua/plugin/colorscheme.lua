local g = vim.g
local cmd = vim.cmd

vim.o.background = 'dark'

-- palette: 'original', 'mix', 'material'
-- background: 'hard', 'medium', 'soft'
g.gruvbox_material_palette = 'original'
g.gruvbox_material_background = 'medium'

-- Enable italics but not in comments
g.gruvbox_material_enable_italic = 1
g.gruvbox_material_disable_italic_comment = 1
g.gruvbox_material_sign_column_background = 'none'
g.gruvbox_material_better_performance = 1

cmd('colorscheme gruvbox-material')
cmd('highlight! link CursorLineNr MoreMsg')
