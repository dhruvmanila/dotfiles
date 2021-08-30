local fn = vim.fn
local api = vim.api
local autocmd = dm.autocmd
local nnoremap = dm.nnoremap

-- Options {{{1

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
setlocal nolist
]]

-- Functions {{{1

local hl_id

-- Return the preview window id in the current tab.
---@return number
local function get_preview_winid()
  for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_option(winid, "previewwindow") then
      return winid
    end
  end
end

-- Highlight the tag which is being currently previewed in the preview window.
local function highlight_tag()
  api.nvim_win_call(get_preview_winid(), function()
    pcall(fn.matchdelete, hl_id)
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    -- Why is this more reliable than `<cword>`? {{{
    --
    -- Because pressing `p` on the word "be" will open the help for
    -- *:behave*/*:be* but as it contains the colon, it won't be highlighted.
    --
    -- There are many such examples:
    --
    --     "run" -> *:rundo*
    --     "by"  -> *byteidx()*
    -- }}}
    -- Pattern explained {{{
    --
    -- We are adding +1 to `col` because `nvim_win_get_cursor` gives us (1, 0)
    -- indexed cursor position.
    --
    -- `:help /ordinary-atom`
    --
    --                  non-whitespace character 1 or more times ┐
    --                                                           │
    --                  in given `lnum`       in given `col`     │
    --                ┌─────────────────┐┌──────────────────────┐├──┐ }}}
    local pattern = [[\%]] .. lnum .. [[l\%]] .. (col + 1) .. [[c\S\+]]
    hl_id = fn.matchadd("Search", pattern)
  end)
end

-- Mappings {{{1

local opts = { buffer = true, nowait = true }

nnoremap("q", "<Cmd>quit<CR>", opts)
nnoremap("<CR>", "<C-]>", opts)
nnoremap("<BS>", "<C-T>", opts)

nnoremap("p", function()
  local ok, err = pcall(vim.cmd, "wincmd }")
  if not ok then
    dm.notify("Help Preview", err, 4)
    return
  end
  highlight_tag()
  -- Do *not* use the autocmd pattern `<buffer>` {{{
  --
  -- The preview window wouldn't be closed when we press `<Enter>` on a tag,
  -- because – if the tag is defined in another file – `CursorMoved` would be
  -- fired in the new buffer.
  -- }}}
  autocmd {
    events = "CursorMoved",
    targets = "*",
    modifiers = "++once",
    command = "pclose",
  }
end, opts)
