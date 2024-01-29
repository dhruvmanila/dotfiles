-- vim.opt_local.textwidth = 80
vim.opt_local.wrap = true
vim.opt_local.conceallevel = 0

vim.api.nvim_buf_create_user_command(0, 'Preview', require('dm.markdown').preview, { bar = true })
