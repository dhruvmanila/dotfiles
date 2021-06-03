-- Ref:
-- sonokai: https://github.com/sainnhe/sonokai
-- gruvbox-material: https://github.com/sainnhe/gruvbox-material
-- gruvbox (lua version): https://github.com/npxbr/gruvbox.nvim
local g = vim.g
local highlight = require("core.utils").highlight

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

-- Generates after/ftplugin/*.vim files for lazy loading
g.gruvbox_material_better_performance = 1

vim.cmd("colorscheme gruvbox-material")

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

-- Telescope.nvim
highlight("TelescopeSelection", { force = true, link = "Visual" })
highlight("TelescopeSelectionCaret", { force = true, link = "Yellow" })
highlight("TelescopeMatching", { force = true, link = "Blue" })
-- highlight('TelescopeBorder', {force = true, link = 'Normal'})
highlight("TelescopePromptPrefix", { force = true, link = "Green" })
highlight("TelescopeAreciboUrl", { force = true, link = "Comment" })
highlight("TelescopeAreciboNumber", { force = true, link = "Blue" })
highlight("TelescopeAreciboPrompt", { force = true, link = "Green" })
highlight("TelescopeAreciboPromptProgress", { force = true, link = "Comment" })

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
-- highlight("NormalFloat", { force = true, link = "Normal" })
-- highlight("FloatBorder", { force = true, link = "Grey" })
highlight("NormalFloat", { guifg = "NONE", guibg = "#2d2d2d" })
highlight("FloatBorder", { guifg = palette.grey1[1], guibg = "#2d2d2d" })
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

-- Compe doc window should be same as that of NormalFloat
highlight("CompeDocumentation", {
  guifg = palette.fg0[1],
  guibg = palette.bg4[1],
})

-- Symbols outline
highlight("FocusedSymbol", { force = true, link = "CurrentWord" })

-- Lir
highlight("LirFloatBorder", { force = true, link = "FloatBorder" })
highlight("LirFloatNormal", { force = true, link = "NormalFloat" })
highlight("LirSymlink", { force = true, link = "GreyItalic" })
highlight("LirEmptyDirText", { force = true, link = "LirSymlink" })

-- Cheat40
highlight("Cheat40Descr", { force = true, link = "Fg" })

-- Vista
highlight("VistaFloat", { force = true, link = "NormalFloat" })
