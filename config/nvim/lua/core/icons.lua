local get_icon = require("nvim-nonicons").get

-- for k,v in pairs(require('nvim-nonicons.mapping')) do
--   print(k, vim.fn.nr2char(v))
-- end

local icons = {
  -- Order should be maintained
  lsp_kind = {
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
  },
  spinner_frames = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
  border = {
    default = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    edgechars = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
    edge = {
      { "🭽", "FloatBorder" },
      { "▔", "FloatBorder" },
      { "🭾", "FloatBorder" },
      { "▕", "FloatBorder" },
      { "🭿", "FloatBorder" },
      { "▁", "FloatBorder" },
      { "🭼", "FloatBorder" },
      { "▏", "FloatBorder" },
    },
  },
  tree = "侮",
  git_logo = "",
  files = "",
  modified = "●", -- 'dot-fill'
  lightbulb = "💡", -- '💡', 'light-bulb'
}

local aliases = {
  error = "x-circle",
  warning = "alert",
  hint = "light-bulb",
  git_branch = "git-branch",
  git_commit = "git-commit",
  diff_added = "diff-added",
  diff_modified = "diff-modified",
  diff_removed = "diff-removed",
  directory = "file-directory",
  lines = "three-bars",
  lists = "list-unordered",
  github = "mark-github",
}

return setmetatable({}, {
  __index = function(_, key)
    local icon = icons[key]
    if icon then
      return icon
    end
    icon = get_icon(aliases[key] or key)
    icons[key] = icon
    return icon
  end,
  _icons = icons,
})
