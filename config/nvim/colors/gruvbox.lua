-- Ref: https://github.com/sainnhe/gruvbox-material/blob/master/colors/gruvbox-material.vim

-- Global style settings. {{{
--     ┌─────────┬─────────────────┐
--     │  State  │      Value      │
--     ├─────────┼─────────────────┤
--     │ Disable │       nil       │
--     ├─────────┼─────────────────┤
--     │ Enable  │ 'italic'/'bold' │
--     └─────────┴─────────────────┘
-- }}}
local italic = "italic"
local bold = "bold"

-- Italic in comments. {{{
--     ┌─────────┬───────────┐
--     │  State  │   Value   │
--     ├─────────┼───────────┤
--     │ Disable │    nil    │
--     ├─────────┼───────────┤
--     │ Enable  │ 'italic'  │
--     └─────────┴───────────┘
-- }}}
local italic_comment = nil

local palette = {
  bg0 = "#282828",
  bg1 = "#32302f",
  bg2 = "#45403d",
  bg3 = "#5a524c",
  bg_current_word = "#3c3836",
  bg_diff_blue = "#0e363e",
  bg_diff_green = "#34381b",
  bg_diff_red = "#402120",
  bg_green = "#b8bb26",
  bg_red = "#cc241d",
  bg_statusline1 = "#32302f",
  bg_statusline2 = "#3a3735",
  bg_statusline3 = "#504945",
  bg_visual_blue = "#374141",
  bg_visual_green = "#3b4439",
  bg_visual_red = "#4c3432",
  bg_visual_yellow = "#4f422e",
  bg_yellow = "#fabd2f",
  bg_float = "#2d2d2d",
  fg = "#ebdbb2",
  grey0 = "#7c6f64",
  grey1 = "#928374",
  grey2 = "#a89984",
}

local base = {
  aqua = "#8ec07c",
  blue = "#83a598",
  green = "#b8bb26",
  orange = "#fe8019",
  purple = "#d3869b",
  red = "#fb4934",
  yellow = "#fabd2f",
}

palette = vim.tbl_extend("error", base, palette)

-- Lua wrapper around `:highlight`
---@param group_name string
---@param args { bg: string, fg: string, sp: string, gui: string, blend: number }
---@param default? boolean
local function highlight(group_name, args, default)
  vim.cmd(
    ("highlight %s %s guifg=%s guibg=%s gui=%s guisp=%s blend=%s"):format(
      default and "default" or "",
      group_name,
      args.fg or "NONE",
      args.bg or "NONE",
      args.gui or "NONE",
      args.sp or "NONE",
      args.blend or "NONE"
    )
  )
end

-- Lua wrapper around `:highlight link`
---@param from_group string
---@param to_group string
---@param force? boolean
local function link(from_group, to_group, force)
  -- When do I need to add a bang after :hi? {{{
  --
  -- When you try to create a link between 2 HGs, and the first one has been
  -- defined with its own attributes:
  --
  --   > :hi MyGroup ctermbg=green guibg=green
  --   > :hi link MyGroup Search
  --   > E414: ...
  --
  --   > :hi! link MyGroup Search
  --        ^
  --
  -- If you execute :hi MyGroup, you'll see that the old attributes are still
  -- there. But the highlighting applied to xxx is given by the link. This shows
  -- that a link has priority over attributes.
  --
  -- You could also have cleared MyGroup:
  --
  --   > :hi MyGroup ctermbg=green guibg=green
  --   > :hi clear MyGroup
  --   > :hi link MyGroup Search
  -- }}}
  if force == nil or force == true then
    vim.cmd("highlight clear " .. from_group)
  end
  vim.cmd(("highlight default link %s %s"):format(from_group, to_group))
end

-- `background` needs to be set *before* `:highlight clear` {{{
--
-- From `:help highlight` /clear
--
--   > Reset all highlighting to the defaults. Removes all highlighting for
--   > groups added by the user! Uses the current value of 'background' to
--   > decide which default colors to use.
--
-- `:highlight clear` causes `$VIMRUNTIME/syntax/syncolor.vim` to be sourced.
-- This needs to know what kind of color scheme you're going to use; light or
-- dark. And for this information to be always correct, `background` needs
-- to be set *before*, not after.
-- }}}
vim.o.background = "dark"
vim.cmd "highlight clear"

if vim.fn.exists "syntax_on" == 1 then
  vim.cmd "syntax reset"
end

vim.g.colors_name = "gruvbox"

-- Predefined Highlight Groups {{{1

-- Why do I need these groups? {{{
--
-- If a plugin is defining its highlight groups, it will mostly be done through
-- default links. Now, if I define a plugin highlight group using attributes
-- because maybe I don't like the default colors, the link will override our
-- definition.
--
--   > :hi MyGroup ctermbg=green guibg=green
--   > :hi! link MyGroup Search |OR| :hi default link MyGroup Search
--   > :hi MyGroup
--
-- As you can see, the link wins. The following highlight groups will be used
-- to link to the plugin highlight groups which needs to be overriden. This is
-- mostly done because a plugin can be lazily loaded and thus will override
-- our definition. The link will ensure that this does not happen.
-- }}}
highlight("Fg", { fg = palette.fg })
highlight("Grey", { fg = palette.grey1 })
highlight("GreyBold", { fg = palette.grey1, gui = bold })
highlight("GreyItalic", { fg = palette.grey1, gui = italic })
highlight("GreyUnderline", { fg = palette.grey1, gui = "underline" })

for name, color in pairs(base) do
  -- Uppercase the first letter of the given string.
  --   'red' -> 'Red'
  name = name:gsub("^%l", string.upper)
  highlight(name, { fg = color })
  highlight(name .. "Bold", { fg = color, gui = bold })
  highlight(name .. "Italic", { fg = color, gui = italic })
  highlight(name .. "Underline", { fg = color, gui = "underline" })
end

-- Default Highlight Groups (`:h highlight-group`) {{{1

highlight("Normal", { fg = palette.fg })
highlight("Terminal", { fg = palette.fg })
highlight("EndOfBuffer", { fg = palette.bg3 })
highlight("FoldColumn", { fg = palette.bg3 })
highlight("Folded", { fg = palette.grey1, bg = palette.bg1 })
highlight("SignColumn", { fg = palette.fg })
highlight("ToolbarLine", { fg = palette.fg })

highlight("IncSearch", { fg = palette.bg0, bg = palette.bg_red })
highlight("Search", { fg = palette.bg0, bg = palette.bg_green })
highlight("ColorColumn", { bg = palette.bg1 })
highlight("Conceal", { fg = palette.bg3 })

highlight("Cursor", { gui = "reverse" })
highlight("HiddenCursor", { gui = "reverse", blend = 100 })
link("vCursor", "Cursor")
link("iCursor", "Cursor")
link("lCursor", "Cursor")
link("CursorIM", "Cursor")
link("TermCursor", "Cursor")

highlight("CursorLine", { bg = palette.bg1 })
highlight("CursorColumn", { bg = palette.bg1 })
highlight("LineNr", { fg = palette.bg3 })
highlight("CursorLineNr", { fg = palette.yellow, gui = "bold" })

highlight("DiffAdd", { bg = palette.bg_diff_green })
highlight("DiffChange", { bg = palette.bg_diff_blue })
highlight("DiffDelete", { bg = palette.bg_diff_red })
highlight("DiffText", { fg = palette.bg0, bg = palette.blue })

highlight("Directory", { fg = palette.green })
highlight("ErrorMsg", { fg = palette.red, gui = "bold,underline" })
highlight("WarningMsg", { fg = palette.yellow, gui = "bold" })
highlight("ModeMsg", { fg = palette.fg, gui = "bold" })
highlight("MoreMsg", { fg = palette.yellow, gui = "bold" })
highlight("MatchParen", { bg = palette.bg2 })
highlight("NonText", { fg = palette.bg3 })
highlight("Whitespace", { fg = palette.bg3 })
highlight("SpecialKey", { fg = palette.bg3 })

highlight("Pmenu", { fg = palette.fg, bg = palette.bg2 })
highlight("PmenuSbar", { bg = palette.bg2 })
highlight("PmenuSel", {
  fg = palette.bg2,
  bg = palette.blue,
  gui = "bold",
})
link("WildMenu", "PmenuSel")
highlight("PmenuThumb", { bg = palette.grey0 })

-- Floating window and border highlights according to the global border style.
if vim.g.border_style == "edge" then
  highlight("NormalFloat", { bg = palette.bg_float })
  highlight("FloatBorder", { fg = palette.grey1, bg = palette.bg_float })
else
  link("NormalFloat", "Normal")
  link("FloatBorder", "Normal")
end

highlight("Question", { fg = palette.yellow })
highlight("SpellBad", { gui = "undercurl", sp = palette.red })
highlight("SpellCap", { gui = "undercurl", sp = palette.blue })
highlight("SpellLocal", { gui = "undercurl", sp = palette.aqua })
highlight("SpellRare", { gui = "undercurl", sp = palette.purple })
highlight("VertSplit", { fg = palette.bg3 })
highlight("Visual", { bg = palette.bg2 })
highlight("VisualNOS", { bg = palette.bg2 })
highlight("QuickFixLine", { fg = palette.purple, gui = "bold" })
highlight("Debug", { fg = palette.orange })
highlight("debugPC", { fg = palette.bg0, bg = palette.green })
highlight("debugBreakpoint", { fg = palette.bg0, palette.red })
highlight("ToolbarButton", { fg = palette.bg0, bg = palette.grey2 })
highlight("Substitute", { fg = palette.bg0, bg = palette.yellow })

-- Statusline {{{2
highlight("StatusLine", { fg = palette.grey2, bg = palette.bg_statusline2 })
highlight("StatusLineTerm", { fg = palette.grey2, bg = palette.bg_statusline2 })
highlight("StatusLineNC", { fg = palette.grey0, bg = palette.bg_statusline1 })
highlight("StatusLineTermNC", {
  fg = palette.grey0,
  bg = palette.bg_statusline1,
})
-- Section highlight groups {{{
--
--     ┌───────┬───────┬──────────────────────────────────┬───────┬───────┐
--     │ User1 │ User2 │                                  │ User2 │ User1 │
--     └───────┴───────┴──────────────────────────────────┴───────┴───────┘
-- }}}
highlight("User1", { fg = palette.bg0, bg = palette.grey2, gui = "bold" })
highlight("User2", { fg = palette.fg, bg = palette.bg_statusline3 })
-- LSP diagnostic groups {{{
--
-- These are arranged in ascending order of the severity level starting from
-- 'User6' for 'Hint' upto 'User9' for 'Error'.
-- }}}
highlight("User6", { fg = palette.blue, bg = palette.bg_statusline2 })
highlight("User7", { fg = palette.aqua, bg = palette.bg_statusline2 })
highlight("User8", { fg = palette.yellow, bg = palette.bg_statusline2 })
highlight("User9", { fg = palette.red, bg = palette.bg_statusline2 })

-- Tabline {{{2
highlight("TabLineSel", { fg = palette.fg, bg = palette.bg0, gui = "bold" })
highlight("TabLine", { fg = "#928374", bg = "#242424" })
highlight("TabLineFill", { fg = "#928374", bg = "#1e1e1e" })

-- Syntax {{{1

highlight("Boolean", { fg = palette.purple })
highlight("Character", { fg = palette.aqua })
highlight("Comment", { fg = palette.grey1, gui = italic_comment })
highlight("Conditional", { fg = palette.red, gui = italic })
highlight("Constant", { fg = palette.aqua })
highlight("Define", { fg = palette.purple, gui = italic })
highlight("Delimiter", { fg = palette.fg })
highlight("Error", { fg = palette.red })
highlight("Exception", { fg = palette.red, gui = italic })
highlight("Float", { fg = palette.purple })
highlight("Function", { fg = palette.green, gui = bold })
highlight("Identifier", { fg = palette.blue })
highlight("Ignore", { fg = palette.grey1 })
highlight("Include", { fg = palette.purple, gui = italic })
highlight("Keyword", { fg = palette.red, gui = italic })
highlight("Label", { fg = palette.orange })
highlight("Macro", { fg = palette.aqua })
highlight("Number", { fg = palette.purple })
highlight("Operator", { fg = palette.orange })
highlight("PreCondit", { fg = palette.purple, gui = italic })
highlight("PreProc", { fg = palette.purple, gui = italic })
highlight("Repeat", { fg = palette.red, gui = italic })
highlight("Special", { fg = palette.yellow })
highlight("SpecialChar", { fg = palette.yellow })
highlight("SpecialComment", { fg = palette.grey1, gui = italic_comment })
highlight("Statement", { fg = palette.red, gui = italic })
highlight("StorageClass", { fg = palette.orange })
highlight("String", { fg = palette.aqua })
highlight("Structure", { fg = palette.orange })
highlight("Tag", { fg = palette.orange })
highlight("Title", { fg = palette.orange, gui = "bold" })
highlight("Todo", { fg = palette.purple, gui = italic_comment })
highlight("Type", { fg = palette.yellow })
highlight("Typedef", { fg = palette.red, gui = italic })
highlight("Underlined", { gui = "underline" })

-- Terminal {{{1

vim.g.terminal_color_0 = palette.bg3
vim.g.terminal_color_1 = palette.red
vim.g.terminal_color_2 = palette.green
vim.g.terminal_color_3 = palette.yellow
vim.g.terminal_color_4 = palette.blue
vim.g.terminal_color_5 = palette.purple
vim.g.terminal_color_6 = palette.cyan
vim.g.terminal_color_7 = palette.fg
vim.g.terminal_color_8 = palette.bg3
vim.g.terminal_color_9 = palette.red
vim.g.terminal_color_10 = palette.green
vim.g.terminal_color_11 = palette.yellow
vim.g.terminal_color_12 = palette.blue
vim.g.terminal_color_13 = palette.purple
vim.g.terminal_color_14 = palette.cyan
vim.g.terminal_color_15 = palette.fg

-- Neovim builtin LSP {{{1
-- Floating Diagnostics {{{2
highlight("DiagnosticFloatingError", {
  fg = palette.red,
  bg = palette.bg_float,
})
highlight("DiagnosticFloatingWarn", {
  fg = palette.yellow,
  bg = palette.bg_float,
})
highlight("DiagnosticFloatingInfo", {
  fg = palette.blue,
  bg = palette.bg_float,
})
highlight("DiagnosticFloatingHint", {
  fg = palette.aqua,
  bg = palette.bg_float,
})

-- Virtual Text Diagnostics {{{2
highlight("DiagnosticVirtualTextError", { fg = palette.red })
highlight("DiagnosticVirtualTextWarn", { fg = palette.yellow })
highlight("DiagnosticVirtualTextInfo", { fg = palette.blue })
highlight("DiagnosticVirtualTextHint", { fg = palette.aqua })

-- Underline Diagnostics {{{2
highlight("DiagnosticUnderlineError", { gui = "undercurl", sp = palette.red })
highlight("DiagnosticUnderlineWarn", { gui = "undercurl", sp = palette.yellow })
highlight("DiagnosticUnderlineInfo", { gui = "undercurl", sp = palette.blue })
highlight("DiagnosticUnderlineHint", { gui = "undercurl", sp = palette.aqua })

-- Sign Diagnostics {{{2
highlight("DiagnosticSignError", { fg = palette.red })
highlight("DiagnosticSignWarn", { fg = palette.yellow })
highlight("DiagnosticSignInfo", { fg = palette.blue })
highlight("DiagnosticSignHint", { fg = palette.aqua })

-- Reference Text {{{2
highlight("LspReferenceText", { bg = palette.bg_current_word })
highlight("LspReferenceRead", { bg = palette.bg_current_word })
highlight("LspReferenceWrite", { bg = palette.bg_current_word })

-- Dashboard {{{1
link("DashboardHeader", "Yellow")
link("DashboardEntry", "AquaBold")
link("DashboardFooter", "Blue")

-- Plugins {{{1
-- gitsigns.nvim {{{2
link("GitSignsAdd", "Green")
link("GitSignsChange", "Blue")
link("GitSignsDelete", "Red")
link("GitSignsChangeDelete", "Purple")

-- lightspeed.nvim {{{2
highlight("LightspeedOneCharMatch", {
  fg = "White",
  gui = "bold,italic,underline",
})

-- lir.nvim {{{2
link("LirFloatBorder", "FloatBorder")
link("LirFloatNormal", "NormalFloat")
link("LirSymlink", "GreyItalic")
link("LirEmptyDirText", "LirSymlink")

-- nvim-notify {{{2

---@see https://github.com/rcarriga/nvim-notify#highlights
for _, section in ipairs { "Border", "Icon", "Title" } do
  link("NotifyERROR" .. section, "Red")
  link("NotifyWARN" .. section, "Yellow")
  link("NotifyINFO" .. section, "Blue")
  link("NotifyDEBUG" .. section, "Aqua")
  link("NotifyTRACE" .. section, "Grey")
end

-- nvim-treesitter {{{2
highlight("TSDanger", { fg = palette.bg0, bg = palette.red, gui = "bold" })
highlight("TSWarning", { fg = palette.bg0, bg = palette.yellow, gui = "bold" })
link("TSConstant", "Fg")
link("TSConstBuiltin", "BlueItalic")
link("TSConstMacro", "BlueItalic")
link("TSConstructor", "GreenBold")
link("TSFuncBuiltin", "GreenBold")
link("TSFuncMacro", "GreenBold")
link("TSMethod", "GreenBold")
link("TSNamespace", "YellowItalic")
link("TSPunctDelimiter", "Grey")
link("TSStringEscape", "Green") -- check
link("TSStringRegex", "Green") -- check
link("TSTagDelimiter", "Green") -- check
link("TSVariableBuiltin", "BlueItalic") -- check

-- telescope.nvim {{{2
link("TelescopeMatching", "Blue")
link("TelescopePromptPrefix", "Yellow")

-- Extended File Types {{{1
-- diff {{{2
-- Used in `git` filetype showing the diff, e.g., fugitive.
link("diffAdded", "Green")
link("diffRemoved", "Red")
link("diffChanged", "Blue")
link("diffOldFile", "Yellow")
link("diffNewFile", "Orange")
link("diffFile", "Aqua")
link("diffLine", "GreyBold")
link("diffIndexLine", "Purple")

-- gitcommit {{{2
-- Remove the italics
link("gitcommitSummary", "Red")
link("gitcommitDiscardedFile", "Grey")
link("gitcommitUntrackedFile", "Grey")

-- help {{{2
link("helpURL", "GreenUnderline")
link("helpHeader", "OrangeBold")
link("helpHyperTextEntry", "YellowBold")
link("helpHyperTextJump", "Yellow")
link("helpExample", "Aqua")
link("helpSectionDelim", "Grey")
link("helpSpecial", "Blue")
link("helpCommand", "Aqua")

-- markdown {{{2
highlight("markdownH1", { fg = palette.red, gui = "bold" })
highlight("markdownH2", { fg = palette.orange, gui = "bold" })
highlight("markdownH3", { fg = palette.yellow, gui = "bold" })
highlight("markdownH4", { fg = palette.green, gui = "bold" })
highlight("markdownH5", { fg = palette.blue, gui = "bold" })
highlight("markdownH6", { fg = palette.purple, gui = "bold" })
link("markdownCode", "Aqua")
link("markdownCodeBlock", "Aqua")
link("markdownUrl", "BlueUnderline")
link("markdownLinkText", "Purple")
link("markdownHeadingRule", "Grey")
link("markdownLinkDelimiter", "Grey")
link("markdownLinkTextDelimiter", "Grey")
link("markdownHeadingDelimiter", "Grey")
link("markdownBoldDelimiter", "Grey")
link("markdownItalicDelimiter", "Grey")
link("markdownBoldItalicDelimiter", "Grey")

-- }}}1
