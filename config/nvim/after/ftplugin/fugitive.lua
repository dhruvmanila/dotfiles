local api = vim.api
local nmap = dm.nmap
local nnoremap = dm.nnoremap

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
setlocal nolist
]]

-- Return the filetype for the buffer contained in the given window.
---@param winnr number
---@return string
local function getwinft(winnr)
  return vim.bo[api.nvim_win_get_buf(winnr)].filetype
end

-- Determine whether we have enough vertical space to move the fugitive buffer
-- in a vertical position.
--
-- Heuristics:
--   - Check if there is enough space available.
--   - Check if there are any vertical splits.
--   - If there are vertical splits, then it should contain only two windows
--     of which the last one should be the Vista window.
--
-- When opening the fugitive buffer for the first time, it is opened at the
-- bottom part of the editor with full width. This will be excluded from the
-- layout so that we only consider the top half of the editor.
--
-- NOTE: This should be called only if we are not already in a vertical position.
---@return boolean
local function has_vertical_space()
  if vim.o.columns <= 140 then
    return false
  end
  local layout = vim.fn.winlayout()
  layout = layout[2][1]
  if layout[1] == "row" then
    local vert_wins = layout[2]
    return #vert_wins == 2
      and getwinft(vert_wins[#vert_wins][2]) == "vista_kind"
  end
  return true
end

-- Determine whether we are in a vertical fugitive window. This is determined
-- by looking at the position of the window.
---@return boolean
local function is_vertical_fugitive()
  local row, col = unpack(api.nvim_win_get_position(0))
  return col > 0 and row == 1
end

local vertical_fugitive = is_vertical_fugitive()
if not vertical_fugitive and has_vertical_space() then
  vim.cmd "wincmd L"
  vertical_fugitive = true
end

local opts = { buffer = true, nowait = true }

-- Setup the keybindings to open the window in the correct split.
if vertical_fugitive or vim.o.columns <= 140 then
  nmap("gh", "g?", opts)
else
  nnoremap("gh", "<Cmd>vertical help fugitive-map<CR>", opts)
  nnoremap("cc", "<Cmd>vertical Git commit<CR>", opts)
end

nmap("q", "gq", opts)
