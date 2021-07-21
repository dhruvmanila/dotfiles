local api = vim.api
local opt_local = vim.opt_local
local nmap = dm.nmap
local nnoremap = dm.nnoremap

opt_local.number = false
opt_local.relativenumber = false
opt_local.list = false

-- Default limit: active window + fugitive window
local limit = 2
local wins = api.nvim_tabpage_list_wins(0)

-- If there is a NvimTree window, then the limit should be 3 as the width of
-- the explorer is negligible.
--
-- This is getting the filetype for the buffer in the first window in the
-- current tabpage and should be kept in sync with the chosen side for the
-- explorer.
if vim.bo[api.nvim_win_get_buf(wins[1])].filetype == "NvimTree" then
  limit = 3
end

local opts = { buffer = true, nowait = true }

-- Open the fugitive buffer in a vertical split when there is space.
if #wins <= limit and api.nvim_win_get_width(0) >= 140 then
  vim.cmd "wincmd L"
  nmap("gh", "g?", opts)
else
  -- For horizontal position, open the help window in the vertical split.
  nnoremap("gh", "<Cmd>vertical help fugitive-map<CR>", opts)
end

nmap("q", "gq", opts)
