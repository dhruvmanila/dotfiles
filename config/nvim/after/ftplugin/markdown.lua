vim.cmd [[
setlocal textwidth=80
]]

vim.api.nvim_buf_create_user_command(
  0,
  'Preview',
  require('dm.markdown').preview,
  { bar = true }
)
