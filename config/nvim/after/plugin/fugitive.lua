local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- 'gs' originally means goto sleep for {count} seconds which is of no use
map("n", "gs", "<Cmd>Git<CR>", opts)
map("n", "<leader>gp", "<Cmd>Git push<CR>", opts)

-- Open current file on GitHub (requires `vim-rhubarb`)
map("n", "<leader>gb", "<Cmd>GBrowse<CR>", opts)
map("v", "<leader>gb", ":GBrowse<CR>", opts)
