local get_icon = require('nvim-nonicons').get
local M = {}

-- for k,v in pairs(require('nvim-nonicons.mapping')) do
--   print(k, vim.fn.nr2char(v))
-- end

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
  error         = get_icon('x-circle-fill'),
  warning       = '',  -- 'alert'
  info          = get_icon('info'),
  hint          = get_icon('question'), -- 'search', 'tools'
  lock          = get_icon('lock'),
  git_branch    = get_icon('git-branch'),
  diff_added    = get_icon('diff-added'),
  diff_modified = get_icon('diff-modified'),
  diff_removed  = get_icon('diff-removed'),
  directory     = get_icon('file-directory'),
  package       = get_icon('package'),
  pencil        = get_icon('pencil'),
  lightbulb     = '💡',  -- Alternative: "💡", 'lightbulb'
}

M.spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' }

return M
