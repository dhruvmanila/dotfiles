vim.keymap.set("n", "<leader>cc", "<Cmd>ColorizerToggle<CR>")

require("colorizer").setup { "css", "html", "lua", "vim" }
