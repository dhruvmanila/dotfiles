local autocmd = dm.autocmd
local nnoremap = dm.nnoremap

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
setlocal nolist
]]

local opts = { buffer = true, nowait = true }

nnoremap("q", "<Cmd>quit<CR>", opts)
nnoremap("<CR>", "<C-]>", opts)
nnoremap("<BS>", "<C-T>", opts)

nnoremap("p", function()
  vim.cmd "wincmd }"
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
