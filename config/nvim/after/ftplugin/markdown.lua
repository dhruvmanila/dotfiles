vim.opt_local.textwidth = 80
vim.opt_local.wrap = false

vim.api.nvim_buf_create_user_command(0, 'Preview', require('dm.markdown').preview, { bar = true })
