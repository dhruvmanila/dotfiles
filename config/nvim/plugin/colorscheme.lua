local g = vim.g
local utils = require "dm.utils"
local highlight = utils.highlight

vim.o.background = "dark"

-- palette: 'original', 'mix', 'material'
g.gruvbox_material_palette = "original"

-- background: 'hard', 'medium', 'soft'
g.gruvbox_material_background = "medium"

g.gruvbox_material_enable_bold = 1
g.gruvbox_material_enable_italic = 1
g.gruvbox_material_disable_italic_comment = 1
g.gruvbox_material_transparent_background = 0
g.gruvbox_material_menu_selection_background = "blue"
g.gruvbox_material_sign_column_background = "none"
g.gruvbox_material_diagnostic_virtual_text = "colored"
-- g.gruvbox_material_visual = 'reverse'
g.gruvbox_material_show_eob = 0

-- Generates after/ftplugin/*.vim files for lazy loading
g.gruvbox_material_better_performance = 1

vim.cmd "colorscheme gruvbox-material"

local palette = vim.fn["gruvbox_material#get_palette"](
  g.gruvbox_material_background,
  g.gruvbox_material_palette
)

highlight("PmenuSel", {
  guifg = palette.bg3[1],
  guibg = palette.blue[1],
  gui = "bold",
})
highlight("HintFloat", { guifg = palette.aqua[1], guibg = palette.bg3[1] })
highlight("GreyItalic", { guifg = palette.grey1[1], gui = "italic" })
highlight("GreyBold", { guifg = palette.grey1[1], gui = "bold" })

-- Current line number
highlight("CursorLineNr", { force = true, link = "MoreMsg" })

-- Floating window and border highlights according to the global border style.
if g.border_style == "edge" then
  highlight("NormalFloat", { guifg = "NONE", guibg = "#2d2d2d" })
  highlight("FloatBorder", { guifg = palette.grey1[1], guibg = "#2d2d2d" })
else
  highlight("NormalFloat", { force = true, link = "Normal" })
  highlight("FloatBorder", { force = true, link = "Normal" })
end

-- Telescope.nvim
highlight("TelescopeSelection", { force = true, link = "Visual" })
highlight("TelescopeMatching", { force = true, link = "Blue" })
highlight("TelescopePromptPrefix", { force = true, link = "Yellow" })

-- Treesitter
highlight("TSParameter", { force = true, link = "Blue" })
highlight("TSProperty", { force = true, link = "Blue" })
highlight("TSField", { force = true, link = "Blue" })
highlight("TSKeyword", { force = true, link = "RedItalic" })
highlight("TSKeywordFunction", { force = true, link = "RedItalic" })
highlight("TSConditional", { force = true, link = "RedItalic" })
highlight("TSRepeat", { force = true, link = "RedItalic" })
highlight("TSException", { force = true, link = "RedItalic" })
highlight("TSInclude", { force = true, link = "RedItalic" })

-- Lsp
highlight("VirtualTextInformation", { force = true, link = "Blue" })
highlight("VirtualTextHint", { force = true, link = "Aqua" })
highlight(
  "LspDiagnosticsFloatingError",
  { force = true, link = "VirtualTextError" }
)
highlight("LspDiagnosticsFloatingWarning", {
  force = true,
  link = "VirtualTextWarning",
})
highlight("LspDiagnosticsFloatingInformation", {
  force = true,
  link = "VirtualTextInformation",
})
highlight(
  "LspDiagnosticsFloatingHint",
  { force = true, link = "VirtualTextHint" }
)

-- Lir
highlight("LirFloatBorder", { force = true, link = "FloatBorder" })
highlight("LirFloatNormal", { force = true, link = "NormalFloat" })
highlight("LirSymlink", { force = true, link = "GreyItalic" })
highlight("LirEmptyDirText", { force = true, link = "LirSymlink" })

-- Cheat40
highlight("Cheat40Descr", { force = true, link = "Fg" })

-- Vista
highlight("VistaFloat", { force = true, link = "NormalFloat" })

-- NvimTree
highlight("NvimTreeIndentMarker", { force = true, link = "Comment" })
