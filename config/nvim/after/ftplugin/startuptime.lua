vim.cmd "wincmd L"

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
]]

dm.nnoremap("q", "<Cmd>quit<CR>", { buffer = true, nowait = true })
