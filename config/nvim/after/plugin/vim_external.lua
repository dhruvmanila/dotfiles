local map = vim.api.nvim_set_keymap
local opts = { noremap = false, silent = true }

vim.g.external_search_engine = "https://duckduckgo.com/?q="

-- Open current buffer directory in finder
map("n", "<leader>ee", "<Plug>(external-explorer)", opts)

-- Similar to netrw
map("n", "gx", "<Plug>(external-browser)", opts)

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
