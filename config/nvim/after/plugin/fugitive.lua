local map = vim.api.nvim_set_keymap

-- 'gs' originally means goto sleep for {count} seconds which is of no use
map("n", "gs", "<Cmd>Git<CR>", { noremap = true })
map("n", "<Leader>gp", "<Cmd>Git push<CR>", { noremap = true })
