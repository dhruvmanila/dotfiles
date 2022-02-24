vim.g.external_search_engine = "https://duckduckgo.com/?q="

-- Open current buffer directory in finder
vim.keymap.set("n", "<leader>ee", "<Plug>(external-explorer)")

-- Similar to netrw
vim.keymap.set("n", "gx", "<Plug>(external-browser)")

-- Required for fugitive + rhubarb as I have disabled netrw.
vim.api.nvim_add_user_command("Browse", "call external#browser(<f-args>)", {
  nargs = 1,
})
