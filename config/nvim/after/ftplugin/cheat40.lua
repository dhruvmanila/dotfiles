local cmd = vim.cmd
local api = vim.api
local nnoremap = dm.nnoremap

-- Set the cursor to About section
api.nvim_win_set_cursor(0, { 7, 0 })

cmd "wincmd ="
cmd "setlocal signcolumn=no"

-- Quick edit the cheat40.txt file
local function edit_cheat40()
  cmd("edit " .. vim.fn.stdpath "config" .. "/cheat40.txt")
  -- Give some extra editing space
  api.nvim_win_set_width(0, api.nvim_win_get_width(0) + 10)
  -- Setup some useful abbreviations
  cmd "iabbrev <buffer> <c «C-»<left>"
  cmd "iabbrev <buffer> <s «Spc»"
  cmd "iabbrev <buffer> < ‹›<left>"
  nnoremap("q", "<Cmd>bdelete<CR>", { buffer = true, nowait = true })
end

nnoremap("e", edit_cheat40, { buffer = true, nowait = true })
nnoremap("<space>", "za", { buffer = true, nowait = true })
