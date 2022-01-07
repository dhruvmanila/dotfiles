vim.cmd "wincmd L"

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
]]

vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = true, nowait = true })
