local nnoremap = dm.nnoremap
local vnoremap = dm.vnoremap

-- 'gs' originally means goto sleep for {count} seconds which is of no use
nnoremap("gs", "<Cmd>Git<CR>")
nnoremap("g<Space>", ":Git<Space>")
nnoremap("<leader>gp", "<Cmd>Git push<CR>")
nnoremap("<leader>gP", "<Cmd>Git push --force-with-lease<CR>")

-- Open current file on GitHub (requires `vim-rhubarb`)
nnoremap("<leader>gb", "<Cmd>GBrowse<CR>")
vnoremap("<leader>gb", ":GBrowse<CR>", { silent = true })
