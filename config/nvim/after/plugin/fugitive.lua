-- 'gs' originally means goto sleep for {count} seconds which is of no use
vim.keymap.set("n", "gs", "<Cmd>Git<CR>")
vim.keymap.set("n", "g<Space>", ":Git<Space>")
vim.keymap.set("n", "<leader>gp", "<Cmd>Git push<CR>")
vim.keymap.set("n", "<leader>gP", "<Cmd>Git push --force-with-lease<CR>")

-- Open current file on GitHub (requires `vim-rhubarb`)
-- Alternative: https://github.com/ruifm/gitlinker.nvim
vim.keymap.set("n", "<leader>gh", "<Cmd>GBrowse<CR>")
vim.keymap.set("v", "<leader>gh", ":GBrowse<CR>", { silent = true })
