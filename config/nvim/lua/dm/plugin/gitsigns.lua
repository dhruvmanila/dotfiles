require("gitsigns").setup {
  signs = {
    add = { hl = "GitSignsAdd", text = "┃" },
    change = { hl = "GitSignsChange", text = "┃" },
    delete = { hl = "GitSignsDelete", text = "_" },
    topdelete = { hl = "GitSignsDelete", text = "‾" },
    changedelete = { hl = "GitSignsChangeDelete", text = "~" },
  },
  numhl = false,
  linehl = false,
  preview_config = {
    border = dm.border[vim.g.border_style],
    row = 1,
    col = 1,
  },
  attach_to_untracked = false,
}
