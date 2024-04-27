vim.cmd.wincmd 'L'

vim.opt_local.number = false
vim.opt_local.relativenumber = false

vim.keymap.set('n', 'q', '<Cmd>quit<CR>', { buffer = true, nowait = true })
