local M = {}

local utils = require 'dm.themes.utils'
local highlight, link = utils.highlight, utils.link

-- Global style settings.
local opts = {
  italic = true,
  bold = true,
  underline = true,

  -- Italic in comments.
  italic_comment = true,
}

local palette_dark = {
  bg_dim = '#1b1b1b',
  bg0 = '#282828',
  bg1 = '#32302f',
  bg2 = '#45403d',
  bg3 = '#5a524c',
  bg_current_word = '#3c3836',
  bg_diff_blue = '#0e363e',
  bg_diff_green = '#34381b',
  bg_diff_red = '#402120',
  bg_green = '#b8bb26',
  bg_red = '#cc241d',
  bg_statusline1 = '#32302f',
  bg_statusline2 = '#3a3735',
  bg_statusline3 = '#504945',
  bg_visual_blue = '#374141',
  bg_visual_green = '#3b4439',
  bg_visual_red = '#4c3432',
  bg_visual_yellow = '#4f422e',
  bg_yellow = '#fabd2f',
  bg_float = '#242424',
  fg = '#ebdbb2',
  grey0 = '#7c6f64',
  grey1 = '#928374',
  grey2 = '#a89984',
}

local base_dark = {
  aqua = '#8ec07c',
  blue = '#83a598',
  green = '#b8bb26',
  orange = '#fe8019',
  purple = '#d3869b',
  red = '#fb4934',
  yellow = '#fabd2f',
}

local palette_light = {
  bg_dim = '#f2e5bc',
  bg0 = '#fbf1c7',
  bg1 = '#f4e8be',
  bg2 = '#eee0b7',
  bg3 = '#ddccab',
  bg_current_word = '#f2e5bc',
  bg_diff_blue = '#e2e6c7',
  bg_diff_green = '#e6eabc',
  bg_diff_red = '#f9e0bb',
  bg_green = '#6f8352',
  bg_red = '#ae5858',
  bg_statusline1 = '#f2e5bc',
  bg_statusline2 = '#f2e5bc',
  bg_statusline3 = '#e5d5ad',
  bg_visual_blue = '#dadec0',
  bg_visual_green = '#dee2b6',
  bg_visual_red = '#f1d9b5',
  bg_visual_yellow = '#fae7b3',
  bg_yellow = '#a96b2c',
  bg_float = '#faeeba',
  fg = '#3c3836',
  grey0 = '#a89984',
  grey1 = '#928374',
  grey2 = '#7c6f64',
}

local base_light = {
  aqua = '#427b58',
  blue = '#076678',
  green = '#79740e',
  orange = '#af3a03',
  purple = '#8f3f71',
  red = '#9d0006',
  yellow = '#b57614',
}

-- Load the dark / light variant of the Gruvbox color scheme.
---@param background "dark"|"light"
function M.load(background)
  local palette, base

  if background == 'dark' then
    palette = vim.tbl_extend('error', base_dark, palette_dark)
    base = base_dark
  else
    palette = vim.tbl_extend('error', base_light, palette_light)
    base = base_light
  end

  highlight('Fg', { fg = palette.fg })
  highlight('Grey', { fg = palette.grey1 })
  highlight('GreyBold', { fg = palette.grey1, bold = opts.bold })
  highlight('GreyItalic', { fg = palette.grey1, italic = opts.italic })
  highlight('GreyUnderline', { fg = palette.grey1, underline = opts.underline })

  for name, color in pairs(base) do
    -- Uppercase the first letter of the given string.
    --   'red' -> 'Red'
    name = name:gsub('^%l', string.upper)
    highlight(name, { fg = color })
    highlight(name .. 'Bold', { fg = color, bold = opts.bold })
    highlight(name .. 'Italic', { fg = color, italic = opts.italic })
    highlight(name .. 'Underline', { fg = color, underline = opts.underline })
  end

  -- Default Highlight Groups (`:h highlight-group`)
  highlight('Normal', { fg = palette.fg, bg = palette.bg0 })
  highlight('Terminal', { fg = palette.fg })
  highlight('EndOfBuffer', { fg = palette.bg3 })
  highlight('FoldColumn', { fg = palette.bg3 })
  highlight('Folded', { fg = palette.grey1, bg = palette.bg1 })
  highlight('SignColumn', { fg = palette.fg })
  highlight('ToolbarLine', { fg = palette.fg })

  highlight('IncSearch', { fg = palette.bg0, bg = palette.bg_red })
  highlight('Search', { fg = palette.bg0, bg = palette.bg_green })
  highlight('ColorColumn', { bg = palette.bg1 })
  highlight('Conceal', { fg = palette.bg3 })

  highlight('Cursor', { reverse = true })
  highlight('HiddenCursor', { reverse = true, blend = 100 })
  link('vCursor', 'Cursor')
  link('iCursor', 'Cursor')
  link('lCursor', 'Cursor')
  link('CursorIM', 'Cursor')
  link('TermCursor', 'Cursor')

  highlight('CursorLine', { bg = palette.bg1 })
  highlight('CursorColumn', { bg = palette.bg1 })
  highlight('LineNr', { fg = palette.bg3 })
  highlight('CursorLineNr', { fg = palette.yellow, bold = true })

  highlight('DiffAdd', { bg = palette.bg_diff_green })
  highlight('DiffChange', { bg = palette.bg_diff_blue })
  highlight('DiffDelete', { bg = palette.bg_diff_red })
  highlight('DiffText', { bg = palette.bg_current_word })

  highlight('Directory', { fg = palette.green })
  highlight('ErrorMsg', { fg = palette.red, bold = true, underline = true })
  highlight('WarningMsg', { fg = palette.yellow, bold = true })
  highlight('ModeMsg', { fg = palette.fg, bold = true })
  highlight('MoreMsg', { fg = palette.yellow, bold = true })
  highlight('MatchParen', { bg = palette.bg2 })
  highlight('NonText', { fg = palette.bg3 })
  highlight('Whitespace', { fg = palette.bg3 })
  highlight('SpecialKey', { fg = palette.bg3 })

  highlight('Pmenu', { fg = palette.fg, bg = palette.bg2 })
  highlight('PmenuSbar', { bg = palette.bg2 })
  highlight('PmenuSel', {
    fg = palette.bg2,
    bg = palette.blue,
    bold = true,
  })
  link('WildMenu', 'PmenuSel')
  highlight('PmenuThumb', { bg = palette.grey0 })

  -- Floating window and border highlights according to the global border style.
  if dm.config.border_style == 'edge' then
    highlight('NormalFloat', { bg = palette.bg_float })
    highlight('FloatBorder', { fg = palette.grey1, bg = palette.bg_float })
  else
    link('NormalFloat', 'Normal')
    link('FloatBorder', 'Normal')
  end

  highlight('Question', { fg = palette.yellow })
  highlight('SpellBad', { undercurl = true, sp = palette.red })
  highlight('SpellCap', { undercurl = true, sp = palette.blue })
  highlight('SpellLocal', { undercurl = true, sp = palette.aqua })
  highlight('SpellRare', { undercurl = true, sp = palette.purple })
  highlight('VertSplit', { fg = palette.bg3 })
  link('WinSeparator', 'VertSplit')
  highlight('Visual', { bg = palette.bg2 })
  highlight('VisualNOS', { bg = palette.bg2 })
  highlight('QuickFixLine', { fg = palette.purple, bold = true })
  highlight('Debug', { fg = palette.orange })
  highlight('debugPC', { fg = palette.bg0, bg = palette.green })
  highlight('debugBreakpoint', { fg = palette.bg0, bg = palette.red })
  highlight('ToolbarButton', { fg = palette.bg0, bg = palette.grey2 })
  highlight('Substitute', { fg = palette.bg0, bg = palette.yellow })

  -- Statusline
  highlight('StatusLine', { fg = palette.grey2, bg = palette.bg_statusline2 })
  highlight('StatusLineTerm', {
    fg = palette.grey2,
    bg = palette.bg_statusline2,
  })
  highlight('StatusLineNC', { fg = palette.grey0, bg = palette.bg_statusline1 })
  highlight('StatusLineTermNC', {
    fg = palette.grey0,
    bg = palette.bg_statusline1,
  })
  -- Section highlight groups
  --
  --     ┌───────┬───────┬──────────────────────────────────┬───────┬───────┐
  --     │ User1 │ User2 │                                  │ User2 │ User1 │
  --     └───────┴───────┴──────────────────────────────────┴───────┴───────┘
  highlight('User1', { fg = palette.bg0, bg = palette.grey2, bold = true })
  highlight('User2', { fg = palette.fg, bg = palette.bg_statusline3 })
  -- LSP diagnostic groups
  --
  -- These are arranged in ascending order of the severity level starting from
  -- 'User6' for 'Hint' upto 'User9' for 'Error'.
  highlight('User6', { fg = palette.blue, bg = palette.bg_statusline2 })
  highlight('User7', { fg = palette.aqua, bg = palette.bg_statusline2 })
  highlight('User8', { fg = palette.yellow, bg = palette.bg_statusline2 })
  highlight('User9', { fg = palette.red, bg = palette.bg_statusline2 })

  -- Tabline
  highlight('TabLineSel', {
    fg = palette.fg,
    bg = palette.bg0,
    bold = true,
    underline = true,
  })
  highlight('TabLine', { fg = palette.grey1, bg = palette.bg_float })
  highlight('TabLineFill', { fg = palette.grey1, bg = palette.bg_dim })

  -- Syntax
  highlight('Boolean', { fg = palette.purple })
  highlight('Character', { fg = palette.aqua })
  highlight('Comment', { fg = palette.grey1, italic = opts.italic_comment })
  highlight('Conditional', { fg = palette.red, italic = opts.italic })
  highlight('Constant', { fg = palette.aqua })
  highlight('Define', { fg = palette.purple, italic = opts.italic })
  highlight('Delimiter', { fg = palette.fg })
  highlight('Error', { fg = palette.red })
  highlight('Exception', { fg = palette.red, italic = opts.italic })
  highlight('Float', { fg = palette.purple })
  highlight('Function', { fg = palette.green, bold = opts.bold })
  highlight('Identifier', { fg = palette.blue })
  highlight('Ignore', { fg = palette.grey1 })
  highlight('Include', { fg = palette.purple, italic = opts.italic })
  highlight('Keyword', { fg = palette.red, italic = opts.italic })
  highlight('Label', { fg = palette.orange })
  highlight('Macro', { fg = palette.aqua })
  highlight('Number', { fg = palette.purple })
  highlight('Operator', { fg = palette.orange })
  highlight('PreCondit', { fg = palette.purple, italic = opts.italic })
  highlight('PreProc', { fg = palette.purple, italic = opts.italic })
  highlight('Repeat', { fg = palette.red, italic = opts.italic })
  highlight('Special', { fg = palette.yellow })
  highlight('SpecialChar', { fg = palette.yellow })
  highlight('SpecialComment', { fg = palette.grey1, italic = opts.italic_comment })
  highlight('Statement', { fg = palette.red, italic = opts.italic })
  highlight('StorageClass', { fg = palette.orange })
  highlight('String', { fg = palette.aqua })
  highlight('Structure', { fg = palette.orange })
  highlight('Tag', { fg = palette.orange })
  highlight('Title', { fg = palette.orange, bold = true })
  highlight('Todo', { fg = palette.yellow, bold = true })
  highlight('Type', { fg = palette.yellow })
  highlight('Typedef', { fg = palette.red, italic = opts.italic })
  highlight('Underlined', { underline = true })

  -- Terminal
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

  -- Neovim builtin LSP
  -- Floating Diagnostics
  highlight('DiagnosticFloatingError', {
    fg = palette.red,
    bg = palette.bg_float,
  })
  highlight('DiagnosticFloatingWarn', {
    fg = palette.yellow,
    bg = palette.bg_float,
  })
  highlight('DiagnosticFloatingInfo', {
    fg = palette.blue,
    bg = palette.bg_float,
  })
  highlight('DiagnosticFloatingHint', {
    fg = palette.aqua,
    bg = palette.bg_float,
  })
  -- Virtual Text Diagnostics
  highlight('DiagnosticVirtualTextError', { fg = palette.red })
  highlight('DiagnosticVirtualTextWarn', { fg = palette.yellow })
  highlight('DiagnosticVirtualTextInfo', { fg = palette.blue })
  highlight('DiagnosticVirtualTextHint', { fg = palette.aqua })
  -- Underline Diagnostics
  highlight('DiagnosticUnderlineError', { undercurl = true, sp = palette.red })
  highlight('DiagnosticUnderlineWarn', { undercurl = true, sp = palette.yellow })
  highlight('DiagnosticUnderlineInfo', { undercurl = true, sp = palette.blue })
  highlight('DiagnosticUnderlineHint', { undercurl = true, sp = palette.aqua })
  -- Sign Diagnostics
  highlight('DiagnosticSignError', { fg = palette.red })
  highlight('DiagnosticSignWarn', { fg = palette.yellow })
  highlight('DiagnosticSignInfo', { fg = palette.blue })
  highlight('DiagnosticSignHint', { fg = palette.aqua })
  -- Reference Text
  highlight('LspReferenceText', { bg = palette.bg_current_word })
  highlight('LspReferenceRead', { bg = palette.bg_current_word })
  highlight('LspReferenceWrite', { bg = palette.bg_current_word })
  -- Codelens
  link('LspCodeLens', 'Grey')
  -- InlayHints
  highlight('LspInlayHint', { bg = palette.bg1, fg = palette.grey1 })
  -- LspInfo
  link('LspInfoBorder', 'FloatBorder')
  -- LspSemanticTokens
  link('@lsp.type.class', 'Structure')
  link('@lsp.type.decorator', 'Function')
  link('@lsp.type.enum', 'Structure')
  link('@lsp.type.enumMember', 'Constant')
  link('@lsp.type.function', 'Function')
  link('@lsp.type.interface', 'Structure')
  link('@lsp.type.macro', 'Macro')
  link('@lsp.type.method', 'Function')
  link('@lsp.type.namespace', 'Structure')
  link('@lsp.type.parameter', 'Identifier')
  link('@lsp.type.property', 'Identifier')
  link('@lsp.type.struct', 'Structure')
  link('@lsp.type.type', 'Type')
  link('@lsp.type.typeParameter', 'TypeDef')
  link('@lsp.type.variable', 'Identifier')

  -- Dashboard
  link('DashboardHeader', 'Yellow')
  link('DashboardEntry', 'AquaBold')
  link('DashboardFooter', 'Blue')

  -- Plugins

  -- copilot.vim
  link('CopilotSuggestion', 'Comment')

  -- gitsigns.nvim
  link('GitSignsAdd', 'Green')
  link('GitSignsChange', 'Blue')
  link('GitSignsDelete', 'Red')
  link('GitSignsTopdelete', 'Red')
  link('GitSignsChangeDelete', 'Purple')

  -- leap.nvim
  highlight('LeapMatch', {
    fg = 'White',
    bold = true,
    italic = true,
    underline = true,
  })

  -- nvim-cmp
  link('CmpItemAbbr', 'Grey')
  link('CmpItemAbbrDeprecated', 'Error')
  link('CmpItemMenu', 'GreyItalic')
  -- Kind highlights
  link('CmpItemKind', 'Yellow')
  link('CmpItemKindText', 'Fg')
  link('CmpItemKindMethod', 'Green')
  link('CmpItemKindFunction', 'Green')
  link('CmpItemKindConstructor', 'Green')
  link('CmpItemKindField', 'Green')
  link('CmpItemKindVariable', 'Blue')
  link('CmpItemKindClass', 'Yellow')
  link('CmpItemKindInterface', 'Yellow')
  link('CmpItemKindModule', 'Yellow')
  link('CmpItemKindProperty', 'Blue')
  link('CmpItemKindUnit', 'Purple')
  link('CmpItemKindValue', 'Purple')
  link('CmpItemKindEnum', 'Yellow')
  link('CmpItemKindKeyword', 'Red')
  link('CmpItemKindSnippet', 'Aqua')
  link('CmpItemKindColor', 'Aqua')
  link('CmpItemKindFile', 'Aqua')
  link('CmpItemKindReference', 'Aqua')
  link('CmpItemKindFolder', 'Aqua')
  link('CmpItemKindEnumMember', 'Purple')
  link('CmpItemKindConstant', 'Blue')
  link('CmpItemKindStruct', 'Yellow')
  link('CmpItemKindEvent', 'Orange')
  link('CmpItemKindOperator', 'Orange')
  link('CmpItemKindTypeParameter', 'Yellow')

  -- nvim-notify
  ---@see https://github.com/rcarriga/nvim-notify#highlights
  for _, section in ipairs { 'Border', 'Icon', 'Title' } do
    link('NotifyERROR' .. section, 'Red')
    link('NotifyWARN' .. section, 'Yellow')
    link('NotifyINFO' .. section, 'Blue')
    link('NotifyDEBUG' .. section, 'Aqua')
    link('NotifyTRACE' .. section, 'Grey')
  end

  -- nvim-treesitter
  link('@annotation', 'Purple')
  link('@attribute', 'Purple')
  link('@boolean', 'Purple')
  link('@character', 'Aqua')
  link('@character.special', 'SpecialChar')
  link('@comment', 'Comment')
  link('@conceal', 'Grey')
  link('@conditional', 'Red')
  link('@constant', 'Fg')
  link('@constant.builtin', 'PurpleItalic')
  link('@constant.macro', 'PurpleItalic')
  link('@constructor', 'GreenBold')
  link('@debug', 'Debug')
  link('@define', 'Define')
  link('@error', 'Error')
  link('@exception', 'Red')
  link('@field', 'Blue')
  link('@float', 'Purple')
  link('@function', 'GreenBold')
  link('@function.builtin', 'GreenBold')
  link('@function.call', 'GreenBold')
  link('@function.macro', 'GreenBold')
  link('@include', 'Red')
  link('@keyword', 'Red')
  link('@keyword.function', 'Red')
  link('@keyword.operator', 'Orange')
  link('@keyword.return', 'Red')
  link('@label', 'Orange')
  link('@math', 'Blue')
  link('@method', 'GreenBold')
  link('@method.call', 'GreenBold')
  link('@namespace', 'YellowItalic')
  link('@none', 'Fg')
  link('@number', 'Purple')
  link('@operator', 'Orange')
  link('@parameter', 'Fg')
  link('@parameter.reference', 'Fg')
  link('@preproc', 'PreProc')
  link('@property', 'Blue')
  link('@punctuation.bracket', 'Fg')
  link('@punctuation.delimiter', 'Grey')
  link('@punctuation.special', 'Blue')
  link('@repeat', 'Red')
  link('@storageclass', 'Orange')
  link('@storageclass.lifetime', 'Orange')
  link('@strike', 'Grey')
  link('@string', 'Aqua')
  link('@string.escape', 'Green')
  link('@string.regex', 'Green')
  link('@string.special', 'SpecialChar')
  link('@symbol', 'Fg')
  link('@tag', 'Orange')
  link('@tag.attribute', 'Green')
  link('@tag.delimiter', 'Green')
  link('@text', 'Green')
  highlight('@text.danger', { fg = palette.red, bold = true })
  highlight('@text.warning', { fg = palette.yellow, bold = true })
  link('@text.diff.add', 'diffAdded')
  link('@text.diff.delete', 'diffRemoved')
  highlight('@text.emphasis', { italic = true })
  link('@text.environment', 'Macro')
  link('@text.environment.name', 'Type')
  link('@text.literal', 'String')
  link('@text.math', 'Blue')
  highlight('@text.note', { bg = palette.bg0, fg = palette.green, bold = true })
  link('@text.reference', 'Constant')
  link('@text.strike', 'Grey')
  highlight('@text.strong', { bold = true })
  link('@text.title', 'Title')
  link('@text.todo', 'Todo')
  link('@text.todo.checked', 'Green')
  link('@text.todo.unchecked', 'Ignore')
  highlight('@text.underline', { underline = true })
  link('@text.uri', 'markdownUrl')
  link('@todo', 'Todo')
  link('@type', 'YellowItalic')
  link('@type.builtin', 'YellowItalic')
  link('@type.definition', 'YellowItalic')
  link('@type.qualifier', 'Orange')
  link('@uri', 'markdownUrl')
  link('@variable', 'Fg')
  link('@variable.builtin', 'PurpleItalic')
  link('TSModuleInfoGood', 'Green')
  link('TSModuleInfoBad', 'Red')
  -- Custom captures
  link('@docstring', '@comment')

  -- nvim-treesitter-context
  link('TreesitterContextSeparator', 'WinSeparator')
  link('TreesitterContext', 'Normal')

  -- telescope.nvim
  link('TelescopeMatching', 'Blue')
  link('TelescopePromptPrefix', 'Yellow')

  -- Extended File Types

  -- diff
  -- Used in `git` filetype showing the diff, e.g., fugitive.
  link('diffAdded', 'Green')
  link('diffRemoved', 'Red')
  link('diffChanged', 'Blue')
  link('diffOldFile', 'Yellow')
  link('diffNewFile', 'Orange')
  link('diffFile', 'Aqua')
  link('diffLine', 'GreyBold')
  link('diffIndexLine', 'Purple')

  -- gitcommit
  -- Remove the italics
  link('gitcommitSummary', 'Red')
  link('gitcommitDiscardedFile', 'Grey')
  link('gitcommitUntrackedFile', 'Grey')

  -- help
  link('helpURL', 'GreenUnderline')
  link('helpHeader', 'OrangeBold')
  link('helpHyperTextEntry', 'YellowBold')
  link('helpHyperTextJump', 'Yellow')
  link('helpExample', 'Aqua')
  link('helpSectionDelim', 'Grey')
  link('helpSpecial', 'Blue')
  link('helpCommand', 'Aqua')

  -- markdown
  highlight('markdownH1', { fg = palette.red, bold = true })
  highlight('markdownH2', { fg = palette.orange, bold = true })
  highlight('markdownH3', { fg = palette.yellow, bold = true })
  highlight('markdownH4', { fg = palette.green, bold = true })
  highlight('markdownH5', { fg = palette.blue, bold = true })
  highlight('markdownH6', { fg = palette.purple, bold = true })
  link('markdownCode', 'Aqua')
  link('markdownCodeBlock', 'Aqua')
  link('markdownUrl', 'BlueUnderline')
  link('markdownLinkText', 'Purple')
  link('markdownHeadingRule', 'Grey')
  link('markdownLinkDelimiter', 'Grey')
  link('markdownLinkTextDelimiter', 'Grey')
  link('markdownHeadingDelimiter', 'Grey')
  link('markdownBoldDelimiter', 'Grey')
  link('markdownItalicDelimiter', 'Grey')
  link('markdownBoldItalicDelimiter', 'Grey')
end

return M
