local nvim_set_keymap = vim.api.nvim_set_keymap
local opts = { noremap = false, silent = true }

nvim_set_keymap("n", "ga", "<Plug>(EasyAlign)", opts)
nvim_set_keymap("x", "ga", "<Plug>(EasyAlign)", opts)
