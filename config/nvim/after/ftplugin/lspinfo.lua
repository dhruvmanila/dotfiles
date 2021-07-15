vim.api.nvim_win_set_config(
  vim.api.nvim_get_current_win(),
  { border = dm.border[vim.g.border_style] }
)
