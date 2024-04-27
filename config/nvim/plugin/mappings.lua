local keymap = vim.keymap

-- NOTE: By using <Cmd> instead of ':', the CmdlineEnter and other related
-- events will not be triggered and thus, no need for <silent>.

-- Command-Line {{{1

---@param key string
---@param fallback string
---@return string
local function navigate_wildmenu(key, fallback)
  if vim.fn.wildmenumode() == 1 then
    return key
  end
  return fallback
end

-- Make <C-p>/<C-n> as smart as <Up>/<Down> {{{
--
-- This will either recall older/recent command-line from history, whose
-- beginning matches the current command-line or move through the wildmenu
-- completion.
-- }}}
keymap.set('c', '<C-p>', function()
  return navigate_wildmenu('<C-p>', '<Up>')
end, { expr = true, desc = 'Go up the command-line history or the wildmenu completion' })
keymap.set('c', '<C-n>', function()
  return navigate_wildmenu('<C-n>', '<Down>')
end, { expr = true, desc = 'Go down the command-line history or the wildmenu completion' })

---@param key string
---@param fallback string
---@return string
local function navigate_search(key, fallback)
  local cmdtype = vim.fn.getcmdtype()
  if cmdtype == '/' or cmdtype == '?' then
    return vim.fn.getcmdline() == '' and '<Up>' or key
  end
  return fallback
end

-- Move between matches without leaving incremental search {{{
--
-- By default, when you search for a pattern, `<C-g>` and `<C-t>` allow you
-- to cycle through all the matches, without leaving the command-line. We remap
-- these commands to `<Tab>` and `<S-Tab>`.
--
-- For an empty command-line, pressing either of the two keys will populate the
-- command-line with the last searched pattern.
--
-- Note dependency on `'wildcharm'` being set to `<C-z>` in order for this to work.
-- }}}
keymap.set('c', '<Tab>', function()
  return navigate_search('<C-g>', '<C-z>')
end, { expr = true })
keymap.set('c', '<S-Tab>', function()
  return navigate_search('<C-t>', '<S-Tab>')
end, { expr = true })

keymap.set('c', '<C-a>', '<Home>')
keymap.set('c', '<C-e>', '<End>')

-- Make <Left>/<Right> move the cursor instead of selecting a different match
-- in the wildmenu. See :h 'wildmenu'
keymap.set('c', '<Left>', '<Space><BS><Left>')
keymap.set('c', '<Right>', '<Space><BS><Right>')

-- This depends on the above mapping for `<Left>` and `<Right>`.
keymap.set('c', '<C-f>', '<Right>', { remap = true })
keymap.set('c', '<C-b>', '<Left>', { remap = true })

-- Normal {{{1

-- Shortcuts for faster save and quit {{{
--
-- '<leader>w': Save only when the buffer is updated
-- '<leader>q': Save the file if modified, and quit
-- '<leader>Q': Save all the modified buffers and exit vim
-- }}}
keymap.set('n', '<leader>w', '<Cmd>silent update<CR>')
keymap.set('n', '<leader>q', '<Cmd>silent xit<CR>')
keymap.set('n', '<leader>Q', '<Cmd>xall<CR>')

-- Toggle fold at current position.
-- See: https://github.com/neovim/neovim/issues/14090#issuecomment-1113090354
keymap.set('n', '<C-i>', '<C-i>')
keymap.set('n', '<Tab>', 'za')

-- Easy way to do `:make`
keymap.set('n', 'm<CR>', '<Cmd>make<CR>')
keymap.set('n', 'm<Space>', ':make ')

keymap.set('n', '<leader>th', '<Cmd>Inspect<CR>')
keymap.set('n', '<leader>tp', '<Cmd>InspectTree<CR>')

-- Make 'gu' toggle between upper and lower case instead of only upper.
-- '~' can also be made to accept motion if 'tildeop' is set to `true`.
keymap.set({ 'n', 'x' }, 'gu', 'g~')

keymap.set('n', '<leader>so', function()
  local filetype = vim.bo.filetype
  if filetype == 'lua' or filetype == 'vim' then
    vim.cmd 'source %'
  end
end, {
  desc = 'Source the current lua or vim file',
})

-- Buffers {{{2
-- Fast switching between last and current file
keymap.set('n', '<Leader><Leader>', '<Cmd>buffer#<CR>')

-- See: https://stackoverflow.com/q/4465095/6064933
keymap.set('n', '<Leader><BS>', '<Cmd>bprevious <bar> bdelete #<CR>', {
  desc = 'Delete a buffer without closing the window',
})

-- Jumps {{{2

---@param letter string
---@return string
local function jump_direction(letter)
  local jump_count = vim.v.count
  if jump_count == 0 then
    return 'g' .. letter
  elseif jump_count > 5 then
    return "m'" .. jump_count .. letter
  end
  return letter
end

-- Performs either of the following tasks as per the `v:count` value:
--   - Move the cursor based on physical lines, not the actual lines.
--   - Store relative line number jumps in the jumplist if they exceed a threshold.
keymap.set('n', 'j', function()
  return jump_direction 'j'
end, { expr = true })
keymap.set('n', 'k', function()
  return jump_direction 'k'
end, { expr = true })

keymap.set('x', 'j', 'gj')
keymap.set('x', 'k', 'gk')

-- If we're inside a long wrapped line, `^` and `0` should go the beginning
-- of the line of the screen (not the beginning of the long line of the file).
--
-- If `wrap` is not set, then this will jump to the beginning/end of the visible
-- line of the screen.
keymap.set({ 'n', 'x' }, '^', 'g^')
keymap.set({ 'n', 'x' }, '0', 'g0')

-- Jump to start (`^`) and end (`$`) of line using the home row keys.
keymap.set({ 'n', 'x' }, 'H', '^')
keymap.set({ 'n', 'x' }, 'L', '$')

-- Quickfix List {{{2

local function quickfix_navigation(cmd, reset)
  -- `v:count1` because we don't want lua to complain.
  for _ = 1, vim.v.count1 do
    local ok, err = pcall(vim.cmd, cmd)
    if not ok then
      -- No more items in the quickfix list; wrap around the edge
      --
      -- Reference: "Vim(cnext):E553: No more items"
      if err:match 'Vim%(%a+%):E553:' then
        vim.cmd(reset)
      end
    end
  end
  vim.cmd 'normal! zz'
end

local quickfix_mappings = {
  { lhs = ']q', cmd = 'cnext', reset = 'cfirst' },
  { lhs = '[q', cmd = 'cprev', reset = 'clast' },
  { lhs = ']l', cmd = 'lnext', reset = 'lfirst' },
  { lhs = '[l', cmd = 'lprev', reset = 'llast' },
  { lhs = ']<C-q>', cmd = 'cnfile', reset = 'cfirst' },
  { lhs = '[<C-q>', cmd = 'cpfile', reset = 'clast' },
  { lhs = ']<C-l>', cmd = 'lnfile', reset = 'lfirst' },
  { lhs = '[<C-l>', cmd = 'lpfile', reset = 'llast' },
}

for _, info in ipairs(quickfix_mappings) do
  keymap.set('n', info.lhs, function()
    quickfix_navigation(info.cmd, info.reset)
  end)
end

keymap.set('n', ']Q', '<Cmd>clast<CR>zz')
keymap.set('n', '[Q', '<Cmd>cfirst<CR>zz')

keymap.set('n', ']L', '<Cmd>llast<CR>zz')
keymap.set('n', '[L', '<Cmd>lfirst<CR>zz')

-- Source: https://superuser.com/q/355325/736190
keymap.set('n', '<leader>x', function()
  for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    if vim.bo[bufnr].filetype == 'qf' then
      vim.api.nvim_win_close(winnr, true)
    end
  end
end, {
  desc = 'Close any opened location and quickfix list in the current tabpage',
})

-- Registers {{{2

-- Yank from current cursor position to the end of the line. Make it consistent
-- with the behavior of 'C', 'D'
keymap.set('n', 'Y', 'y$')

-- Automatically jump to the end of text on yank and paste
-- `] (backticks) to the last character of previously changed or yanked text
keymap.set('n', 'p', 'p`]')
keymap.set('x', 'y', 'y`]')

-- Delete without overriding the paste register
keymap.set({ 'n', 'x' }, '<leader>d', '"_d')

-- Prevent 'x/X' and 'c/C' from overriding what's in the clipboard
keymap.set({ 'n', 'x' }, 'x', '"_x')
keymap.set({ 'n', 'x' }, 'X', '"_X')
keymap.set({ 'n', 'x' }, 'c', '"_c')
keymap.set({ 'n', 'x' }, 'C', '"_C')

-- Search {{{2

-- Rationale: {{{
--
-- The direction of `n` and `N` depends on whether `/` or `?` was used for
-- searching forward or backward respectively.
--
-- This will make sure that `n` will always search forward and `N` backward.
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-N
-- }}}
-- FIXME: this does not open the folds by default as explained in `:h 'foldopen'`
-- adding 'zv' at the end causes the highlighting to lose
keymap.set('n', 'n', "'Nn'[v:searchforward] . 'zvzz'", { expr = true })
keymap.set('n', 'N', "'nN'[v:searchforward] . 'zvzz'", { expr = true })

-- Don't move the cursor to the next match
-- FIXME: if the cursor is not at the start of the word, it is not highlighted
keymap.set('n', '*', '*``')
keymap.set('n', '#', '#``')

-- Substitute {{{2

-- Multiple Cursor Replacement
--
-- Source: http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
--
--                     ┌ populate search register with word under cursor
--                     │
--                     │┌ get back to where we were
--                     ││
--                     ││ ┌ change next occurrence of last used search pattern
--                     │├┐├─┐
keymap.set('n', 'cn', '*``cgn', {
  desc = 'Change |word| under cursor, repeat (`.`) or skip (`n`) in forward direction',
})
keymap.set('n', 'cN', '*``cgN', {
  desc = 'Change |word| under cursor, repeat (`.`) or skip (`N`) in backward direction',
})

-- Similarly in Visual mode
vim.g.mc = vim.keycode [[y/\V<C-r>=escape(@", '/')<CR><CR>]]
keymap.set('x', 'cn', [[g:mc . "``cgn"]], {
  expr = true,
  desc = 'Change visually selected text, repeat (`.`) or skip (`n`) in forward direction',
})
keymap.set('x', 'cN', [[g:mc . "``cgN"]], {
  expr = true,
  desc = 'Change visually selected text, repeat (`.`) or skip (`N`) in backward direction',
})

keymap.set('n', '<Leader>su', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], {
  desc = 'Substitute |word| under cursor globally',
})
keymap.set('x', '<leader>su', [["zy:%s/\<<C-r><C-o>"\>//g<Left><Left>]], {
  desc = 'Substitute visually selected text globally',
})

-- Tabs {{{2

---@param forward boolean
local function move_tabpage(forward)
  local tabpagenr = vim.api.nvim_tabpage_get_number(0)
  if forward and tabpagenr == #vim.api.nvim_list_tabpages() then
    vim.cmd 'tabmove 0'
  elseif not forward and tabpagenr == 1 then
    vim.cmd 'tabmove $'
  elseif forward then
    vim.cmd 'tabmove +1'
  else
    vim.cmd 'tabmove -1'
  end
end

keymap.set('n', ']t', function()
  move_tabpage(true)
end, {
  desc = 'Move the current tabpage in the forward direction wrapping around',
})
keymap.set('n', '[t', function()
  move_tabpage(false)
end, {
  desc = 'Move the current tabpage in the backward direction wrapping around',
})

-- Tab navigation
--   - `<leader>n` goes to nth tab
--   - `<leader>0` goes to the last tab as on a normal keyboard the
--     numeric keys are from 1,2,...0.
for i = 1, 9 do
  keymap.set('n', '<leader>' .. i, i .. 'gt', {
    desc = ('Go to tabpage %d'):format(i),
  })
end
keymap.set('n', '<leader>0', '<Cmd>tablast<CR>', {
  desc = 'Go to the last tabpage',
})

-- Windows {{{2

-- Toggle zoom {{{
--
-- The state is stored in a *window* variable which means each window can be
-- zoomed in and out on its own.
-- }}}
keymap.set('n', '<leader>z', function()
  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    return
  end
  if vim.w.zoom_restore then
    vim.cmd(vim.w.zoom_restore)
    vim.w.zoom_restore = nil
  else
    vim.w.zoom_restore = vim.fn.winrestcmd()
    vim.cmd 'wincmd |'
    vim.cmd 'wincmd _'
  end
end, { desc = 'Toggle window zoom' })

-- Quicker window movement
keymap.set('n', '<C-j>', '<C-w>j')
keymap.set('n', '<C-k>', '<C-w>k')
keymap.set('n', '<C-h>', '<C-w>h')
keymap.set('n', '<C-l>', '<C-w>l')

-- Use the arrow keys to resize windows
keymap.set('n', '<Down>', '<Cmd>resize -2<CR>')
keymap.set('n', '<Up>', '<Cmd>resize +2<CR>')
keymap.set('n', '<Left>', '<Cmd>vertical resize -2<CR>')
keymap.set('n', '<Right>', '<Cmd>vertical resize +2<CR>')

-- }}}2

-- Objects {{{1

-- `il` = in line (operate on the text between first and last non-whitespace on
-- the line). Useful to copy a line and paste it characterwise (in the middle of
-- another line)
keymap.set('x', 'il', '_og_')
keymap.set('o', 'il', '<Cmd>normal vil<CR>')

-- We don't need to create `al` (around line) to operate on the whole line
-- including newline, because `_` can be used instead. But still, it brings
-- consistency/symmetry.
keymap.set('x', 'al', 'V')
keymap.set('o', 'al', '_')

-- Entire buffer
keymap.set('x', 'ie', 'gg0oG$')
keymap.set('o', 'ie', ':<C-U>exe "norm! m`" <Bar> keepjumps norm! ggVG<CR>``')

-- Terminal {{{1

-- Normal mode in terminal
keymap.set('t', '<Esc>', [[<C-\><C-n>]])

-- Movements in terminal
-- keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
-- keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
-- keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
-- keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])

-- Visual {{{1

-- Search only in Visual selection
keymap.set('x', '/', function()
  -- If we've selected only 1 line, we probably don't want to look for a pattern;
  -- instead, we just want to extend the selection.
  if vim.fn.line 'v' == vim.fn.line '.' then
    return '/'
  end
  return [[<C-\><C-n>/\%V]]
end, { expr = true })

-- Repeat last edit on all the visually selected lines with dot.
keymap.set('x', '.', ':normal! .<CR>')

-- Search for visually selected text using '*' and '#'
-- https://vim.fandom.com/wiki/Search_for_visually_selected_text#Simple
keymap.set('x', '*', [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
keymap.set('x', '#', [[y?\V<C-R>=escape(@",'/?')<CR><CR>]])

-- Capital JK move code lines/blocks up & down (only in visual mode)
keymap.set('x', 'J', [[:move '>+1<CR>gv=gv]])
keymap.set('x', 'K', [[:move '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
keymap.set('x', '<', '<gv')
keymap.set('x', '>', '>gv')

-- Repeat last macro on all the visually selected lines with `@{reg}`.
keymap.set('x', '@', [[:<C-U>execute ":* normal @".getcharstr()<CR>]], {
  silent = true,
})

-- Make blockwise Visual mode, especially Visual-block Inserting/Appending,
-- more useful.
--
-- v_b_I = Visual-block Insert (`:h v_b_I`)
-- v_b_A = Visual-block Append (`:h v_b_A`)
--
--   > Make |v_b_I| and |v_b_A| available in all kinds of Visual mode.
--   > Adjust the selected area to be intuitive before doing blockwise insertion.
--
-- Source: https://github.com/kana/vim-niceblock/blob/master/doc/niceblock.txt
local niceblock_keys = {
  -- Terminal code `^V` because that's what `nvim_get_mode` returns
  -- for visual-block mode (`:h i_CTRL_V`) ──┐
  --                                         │
  ['I'] = { v = '<C-V>I', V = '<C-V>^o^I', [''] = 'I' },
  ['A'] = { v = '<C-V>A', V = '<C-V>0o$A', [''] = 'A' },
  ['gI'] = { v = '<C-V>0I', V = '<C-V>0o$I', [''] = '0I' },
}

---@param key string
---@return string
local function niceblock(key)
  local mode = vim.api.nvim_get_mode().mode
  return niceblock_keys[key][mode]
end

-- Like |v_b_I|, but:
--
--   * It's available in all kinds of Visual mode.
--   * It adjusts the selected area to get intuitive result after blockwise
--     insertion if the current mode is not blockwise.
--   * In linewise Visual mode, text is inserted before the first non-blank column.
keymap.set('x', 'I', function()
  return niceblock 'I'
end, { expr = true })

-- Like |v_I|, but it's corresponding to |v_b_A| instead of |v_b_I|.
keymap.set('x', 'A', function()
  return niceblock 'A'
end, { expr = true })

-- Like |v_I|, but it behaves like |gI| in Normal mode. Text is always inserted
-- before the first column.
keymap.set('x', 'gI', function()
  return niceblock 'gI'
end, { expr = true })

-- Replace the selection without overriding the paste register and jump to the
-- end of text.
--
-- By default, `v_p` and `v_P` do the same thing, so we can remap this to `P`
-- and keep the original behavior on `p`.
keymap.set('x', 'p', '"_dP`]')

-- }}}1
