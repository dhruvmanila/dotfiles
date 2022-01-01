local nmap = dm.nmap
local nnoremap = dm.nnoremap

vim.g.external_search_engine = "https://duckduckgo.com/?q="

-- Open current buffer directory in finder
nmap("<leader>ee", "<Plug>(external-explorer)")

-- Similar to netrw
nmap("gx", "<Plug>(external-browser)")

-- GitHub notifications page
nnoremap(
  "<leader>eg",
  '<Cmd>call external#browser("https://github.com/notifications")<CR>'
)

-- Required for fugitive + rhubarb as I have disabled netrw.
vim.api.nvim_add_user_command("Browse", "call external#browser(<f-args>)", {
  force = true,
  nargs = 1,
})
