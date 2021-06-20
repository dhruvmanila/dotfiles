local map = vim.api.nvim_set_keymap
local opts = { noremap = false, silent = true }

vim.g.external_search_engine = "https://duckduckgo.com/?q="

map("n", "<leader>ee", "<Plug>(external-editor)", opts)
map("n", "<leader>en", "<Plug>(external-explorer)", opts)
map("n", "<leader>eb", "<Plug>(external-browser)", opts)

opts.noremap = true

-- GitHub notifications page
map(
  "n",
  "<leader>eg",
  '<Cmd>call external#browser("https://github.com/notifications")<CR>',
  opts
)

-- Required for fugitive + rhubarb as I have disabled netrw.
dm.command { "Browse", "call external#browser(<f-args>)", nargs = 1 }
