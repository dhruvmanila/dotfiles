local get_icon = require("nvim-nonicons").get
local M = {}

-- for k,v in pairs(require('nvim-nonicons.mapping')) do
--   print(k, vim.fn.nr2char(v))
-- end

M.lsp_kind = {
  { "", "Text" },
  { "", "Method" },
  { "", "Function" },
  { "", "Constructor" },
  { "", "Field" },
  { "", "Variable" },
  { "", "Class" },
  { "", "Interface" },
  { "", "Module" },
  { "", "Property" },
  { "", "Unit" },
  { "", "Value" },
  { "", "Enum" },
  { "", "Keyword" },
  { "", "Snippet" },
  { "", "Color" },
  { "", "File" },
  { "", "Reference" },
  { "", "Folder" },
  { "", "EnumMember" },
  { "", "Constant" },
  { "", "Struct" },
  { "", "Event" },
  { "", "Operator" },
  { "", "TypeParameter" },
}

M.icons = {
  tree = "侮",
  git_logo = "",
  error = get_icon("x-circle-fill"),
  warning = "", -- 'alert'
  info = get_icon("info"),
  hint = get_icon("light-bulb"), -- 'search', 'tools', 'question'
  lock = get_icon("lock"),
  git_branch = get_icon("git-branch"),
  git_commit = get_icon("git-commit"),
  -- diff_added    = get_icon('diff-added'),
  -- diff_modified = get_icon('diff-modified'),
  -- diff_removed  = get_icon('diff-removed'),
  file = get_icon("file"),
  files = "",
  directory = get_icon("file-directory"),
  package = get_icon("package"),
  modified = "●", -- 'dot-fill'
  terminal = get_icon("terminal"),
  lightbulb = "💡", -- '💡', 'light-bulb'
  lines = get_icon("three-bars"),
  lists = get_icon("list-unordered"),
  tag = get_icon("tag"), -- ''
  telescope = get_icon("telescope"),
  book = get_icon("book"),
  github = get_icon("mark-github"),
  rocket = get_icon("rocket"),
  history = get_icon("history"),
  globe = get_icon("globe"),
  stopwatch = get_icon("stopwatch"),
  pin = get_icon("pin"),
  tools = get_icon("tools"),
  gear = get_icon("gear"),
}

M.border = {
  default = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  edge = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
}

M.spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

return M
