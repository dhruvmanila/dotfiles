vim.api.nvim_set_keymap(
  "n",
  "<Leader>cc",
  "<Cmd>ColorizerToggle<CR>",
  { noremap = true }
)

require("colorizer").setup()
