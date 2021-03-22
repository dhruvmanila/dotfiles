-- Ref: https://github.com/Yggdroot/indentLine
local g = vim.g

-- | ¦ ┆ │ ┊ │
g.indentLine_char = '│'

g.indentLine_fileTypeExclude = {
  'startify',
  'help',
  'packer',
  'markdown',
  'txt'
}

-- Color is set by 'gruvbox-material' color scheme
-- g.indentLine_setColors = 0
