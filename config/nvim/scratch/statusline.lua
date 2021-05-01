---Mode data
---1. Full  2. Short  3. Highlight
local modes = {
  n      = {'NORMAL',    'N',    'StGreyBold'},
  no     = {'N·OpPd',    'N·OP', 'StGreyBold'},
  i      = {'INSERT',    'I',    'StGreenBold'},
  ic     = {'I·COMPL',   'I·CO', 'StGreenBold'},
  c      = {'COMMAND',   'C',    'StBlueBold'},
  v      = {'VISUAL',    'V',    'StRedBold'},
  V      = {'V·LINE',    'V·L',  'StRedBold'},
  [''] = {'V·BLOCK',   'V·B',  'StRedBold'},
  s      = {'SELECT',    'S',    'StRedBold'},
  S      = {'S·LINE',    'S·L',  'StRedBold'},
  [''] = {'S·BLOCK',   'S·B',  'StRedBold'},
  R      = {'REPLACE',   'R',    'StYellowBold'},
  Rv     = {'V·REPLACE', 'V·R',  'StYellowBold'},
  ['r']  = {'PROMPT',    'P',    'StGreyBold'},
  ['r?'] = {'CONFIRM',   'C',    'StGreyBold'},
  rm     = {'MORE',      'M',    'StGreyBold'},
  ['!']  = {'SHELL',     '!',    'StGreyBold'},
  t      = {'TERMINAL',  'T',    'StPurpleBold'},
}

local mode = {
  'terminal',
  'gitcommit',
}

---Return the mode component.
---the mode text.
---@return string
local function mode_component()
  local mode_info = modes[fn.mode()]
  return wrap_hl(mode_info[3]) .. ' ' .. mode_info[1] .. ' %*'
end


