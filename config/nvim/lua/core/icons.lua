local get_icon = require('nvim-nonicons').get
local M = {}

M.lsp_kind = {
  Text          = '',
  Method        = '',
  Function      = '',
  Constructor   = '',
  Field         = '',
  Variable      = '',
  Class         = '',
  Interface     = '',
  Module        = '',
  Property      = '',
  Unit          = '',
  Value         = '',
  Enum          = '',
  Keyword       = '',
  Snippet       = '',
  Color         = '',
  File          = '',
  Reference     = '',
  Folder        = '',
  EnumMember    = '',
  Constant      = '',
  Struct        = '',
  Event         = '',
  Operator      = '',
  TypeParameter = '',
}

M.icons = {
  tree          = '侮',
  git_logo      = '',
  error         = '✘',
  warning       = '',
  hint          = '',
  info          = get_icon('info'),
  question      = get_icon('question'),
  lock          = get_icon('lock'),
  git_branch    = get_icon('git-branch'),
  diff_added    = get_icon('diff-added'),
  diff_modified = get_icon('diff-modified'),
  diff_removed  = get_icon('diff-removed'),
  directory     = get_icon('file-directory'),
  package       = get_icon('package'),
  pencil        = get_icon('pencil'),
  lightbulb     = get_icon('light-bulb'),  -- Alternative: "💡"
}

M.spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' }

return M
