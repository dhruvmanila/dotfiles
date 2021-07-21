local nmap = dm.nmap
local nnoremap = dm.nnoremap

vim.g.external_search_engine = "https://duckduckgo.com/?q="

-- Open current buffer directory in finder
nmap { "<leader>ee", "<Plug>(external-explorer)" }

-- Similar to netrw
nmap { "gx", "<Plug>(external-browser)" }

-- GitHub notifications page
nnoremap {
  "<leader>eg",
  '<Cmd>call external#browser("https://github.com/notifications")<CR>',
}

-- Required for fugitive + rhubarb as I have disabled netrw.
dm.command("Browse", "call external#browser(<f-args>)", { nargs = 1 })
