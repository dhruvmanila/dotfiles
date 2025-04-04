vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.list = false

do
  local hl_id

  -- Return the preview window id in the current tab if it exists.
  ---@return number?
  local function find_preview_winid()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.wo[winid].previewwindow then
        return winid
      end
    end
  end

  -- Highlight the tag which is being currently previewed in the preview window.
  local function highlight_tag()
    local preview_winid = find_preview_winid()
    if not preview_winid then
      return
    end
    vim.api.nvim_win_call(preview_winid, function()
      pcall(vim.fn.matchdelete, hl_id)
      local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
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
      hl_id = vim.fn.matchadd('Search', pattern)
    end)
  end

  vim.keymap.set('n', 'p', function()
    local ok, err = pcall(vim.cmd.wincmd, '}')
    if not ok then
      dm.notify('Help Preview', err, vim.log.levels.ERROR)
      return
    end
    highlight_tag()
    -- Do *not* use the autocmd pattern `<buffer>` {{{
    --
    -- The preview window wouldn't be closed when we press `<Enter>` on a tag,
    -- because – if the tag is defined in another file – `CursorMoved` would be
    -- fired in the new buffer.
    -- }}}
    vim.api.nvim_create_autocmd('CursorMoved', {
      once = true,
      command = 'pclose',
    })
  end, {
    buffer = true,
    nowait = true,
    desc = 'Open help for an identifier under the cursor',
  })
end

local opts = { buffer = true, nowait = true }

vim.keymap.set('n', 'q', '<Cmd>quit<CR>', opts)
vim.keymap.set('n', '<CR>', '<C-]>', opts)
vim.keymap.set('n', '<BS>', '<C-T>', opts)
