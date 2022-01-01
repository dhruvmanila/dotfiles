local escape = dm.escape
local cmap = dm.cmap
local nnoremap = dm.nnoremap
local xnoremap = dm.xnoremap
local onoremap = dm.onoremap
local cnoremap = dm.cnoremap
local inoremap = dm.inoremap
local tnoremap = dm.tnoremap

-- NOTE: By using <Cmd> instead of ':', the CmdlineEnter and other related
-- events will not be triggered and thus, no need for <silent>.

-- Command-Line {{{1

-- Make <C-p>/<C-n> as smart as <Up>/<Down> {{{
--
-- This will either recall older/recent command-line from history, whose
-- beginning matches the current command-line or move through the wildmenu
-- completion.
-- }}}
cnoremap("<C-p>", "wildmenumode() ? '<C-p>' : '<Up>'", { expr = true })
cnoremap("<C-n>", "wildmenumode() ? '<C-n>' : '<Down>'", { expr = true })

---Navigate search without leaving incremental mode.
---@param key string
---@param fallback string
local function navigate_search(key, fallback)
  local cmdtype = vim.fn.getcmdtype()
  if cmdtype == "/" or cmdtype == "?" then
    return vim.fn.getcmdline() == "" and escape "<Up>" or escape(key)
  end
  return escape(fallback)
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
cnoremap("<Tab>", partial(navigate_search, "<C-g>", "<C-z>"), { expr = true })
cnoremap("<S-Tab>", partial(navigate_search, "<C-t>", "<S-Tab>"), {
  expr = true,
})

cnoremap("<C-a>", "<Home>")
cnoremap("<C-e>", "<End>")

cmap("<C-f>", "<Right>")
cmap("<C-b>", "<Left>")

-- Make <Left>/<Right> move the cursor instead of selecting a different match
-- in the wildmenu. See :h 'wildmenu'
cnoremap("<Left>", "<Space><BS><Left>")
cnoremap("<Right>", "<Space><BS><Right>")

-- Insert {{{1

-- Movement in insert mode
-- inoremap("<C-h>", "<C-o>h")
-- inoremap("<C-l>", "<C-o>l")
-- inoremap("<C-j>", "<C-o>j")
-- inoremap("<C-k>", "<C-o>k")

-- Change the case for the word under cursor in insert mode
-- '<C-u>': (u)ppercase
-- '<C-t>': (t)itlecase
-- inoremap("<C-u>", "<esc>viwUea")
inoremap("<C-t>", "<esc>b~lea")

-- Normal {{{1

-- Shortcuts for faster save and quit {{{
--
-- '<leader>w': Save only when the buffer is updated
-- '<leader>q': Save the file if modified, and quit
-- 'Q': Save all the modified buffers and exit vim
-- }}}
nnoremap("<leader>w", "<Cmd>silent update<CR>")
nnoremap("<leader>q", "<Cmd>silent xit<CR>")
nnoremap("Q", "<Cmd>xall<CR>")

-- Rationale: {{{
--
-- In the terminal, `<Tab>` and `<C-i>` is seen as the same thing by Vim. To
-- avoid collision between the two keys, we will map any unused key (`<F6>`)
-- to `<C-i>` and program the terminal to send `<F6>` on `<C-i>`.
--
-- This will allow us to use `<Tab>` for toggling folds.
--
-- For kitty, it is configured in `~/.config/kitty/kitty.conf`.
-- For Terminal and iTerm2, it is configured via Karabiner-elements.
-- }}}
nnoremap("<F6>", "<C-i>")

-- Toggle fold at current position.
nnoremap("<Tab>", "za")

-- Easy way to do `:make`
nnoremap("m<CR>", "<Cmd>make<CR>")
nnoremap("m<Space>", ":make ")

-- Make 'gu' toggle between upper and lower case instead of only upper.
-- '~' can also be made to accept motion if 'tildeop' is set to `true`.
nnoremap("gu", "g~")
xnoremap("gu", "g~")

-- Source files (only for lua or vim files)
nnoremap("<leader>so", function()
  local filetype = vim.bo.filetype
  if filetype == "lua" or filetype == "vim" then
    vim.cmd "source %"
  end
end)

-- Buffers {{{2
nnoremap("]<Leader>", "<Cmd>execute v:count .. 'bnext'<CR>")
nnoremap("[<Leader>", "<Cmd>execute v:count .. 'bprev'<CR>")
nnoremap("<Leader><BS>", "<Cmd>bdelete<CR>")

-- Fast switching between last and current file
nnoremap("<Leader><Leader>", "<Cmd>buffer#<CR>")

-- Close a buffer without closing the window
-- See: https://stackoverflow.com/q/4465095/6064933
nnoremap("<leader>bd", "<Cmd>bprevious <bar> bdelete #<CR>")

-- Jumps {{{2

---@param letter string
---@return string
local function jump_direction(letter)
  local jump_count = vim.v.count
  if jump_count == 0 then
    return "g" .. letter
  elseif jump_count > 5 then
    return "m'" .. jump_count .. letter
  end
  return letter
end

-- Performs either of the following tasks as per the `v:count` value:
--   - Move the cursor based on physical lines, not the actual lines.
--   - Store relative line number jumps in the jumplist if they exceed a threshold.
nnoremap("j", partial(jump_direction, "j"), { expr = true })
nnoremap("k", partial(jump_direction, "k"), { expr = true })
xnoremap("j", "gj")
xnoremap("k", "gk")

-- If we're inside a long wrapped line, `^` and `0` should go the beginning
-- of the line of the screen (not the beginning of the long line of the file).
--
-- If `wrap` is not set, then this will jump to the beginning/end of the visible
-- line of the screen.
nnoremap("^", "g^")
xnoremap("^", "g^")
nnoremap("0", "g0")
xnoremap("0", "g0")

-- Jump to start (`^`) and end (`$`) of line using the home row keys.
nnoremap("H", "^")
xnoremap("H", "^")
nnoremap("L", "g_")
xnoremap("L", "g_")

-- Quickfix List {{{2

local function quickfix_navigation(cmd, reset)
  -- `v:count1` because we don't want lua to complain.
  for _ = 1, vim.v.count1 do
    local ok, err = pcall(vim.cmd, cmd)
    if not ok then
      -- No more items in the quickfix list; wrap around the edge
      --
      -- Reference: "Vim(cnext):E553: No more items"
      if err:match "^Vim%(%a+%):E553:" then
        vim.cmd(reset)
      end
    end
  end
end

nnoremap("]q", partial(quickfix_navigation, "cnext", "cfirst"))
nnoremap("[q", partial(quickfix_navigation, "cprev", "clast"))

nnoremap("]l", partial(quickfix_navigation, "lnext", "lfirst"))
nnoremap("[l", partial(quickfix_navigation, "lprev", "llast"))

nnoremap("]Q", "<Cmd>clast<CR>")
nnoremap("[Q", "<Cmd>cfirst<CR>")

nnoremap("]L", "<Cmd>llast<CR>")
nnoremap("[L", "<Cmd>lfirst<CR>")

nnoremap("]<C-q>", partial(quickfix_navigation, "cnfile", "cfirst"))
nnoremap("[<C-q>", partial(quickfix_navigation, "cpfile", "clast"))

nnoremap("]<C-l>", partial(quickfix_navigation, "lnfile", "lfirst"))
nnoremap("[<C-l>", partial(quickfix_navigation, "lpfile", "llast"))

-- Close location list or quickfix list if they are present,
-- Source: https://superuser.com/q/355325/736190
nnoremap("<leader>x", "<Cmd>windo lclose <bar> cclose<CR>")

-- Registers {{{2

-- Yank from current cursor position to the end of the line. Make it consistent
-- with the behavior of 'C', 'D'
nnoremap("Y", "y$")

-- Automatically jump to the end of text on yank and paste
-- `] (backticks) to the last character of previously changed or yanked text
nnoremap("p", "p`]")
xnoremap("y", "y`]")

-- Delete without overriding the paste register
nnoremap("<leader>d", '"_d')
xnoremap("<leader>d", '"_d')

-- Prevent 'x/X' and 'c/C' from overriding what's in the clipboard
nnoremap("x", '"_x')
xnoremap("x", '"_x')
nnoremap("X", '"_X')
xnoremap("X", '"_X')
nnoremap("c", '"_c')
xnoremap("c", '"_c')
nnoremap("C", '"_C')
xnoremap("C", '"_C')

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
nnoremap("n", "'Nn'[v:searchforward] . 'zv'", { expr = true })
nnoremap("N", "'nN'[v:searchforward] . 'zv'", { expr = true })

-- Don't move the cursor to the next match
-- FIXME: if the cursor is not at the start of the word, it is not highlighted
nnoremap("*", "*``")
nnoremap("#", "#``")

-- Substitute {{{2

-- Multiple Cursor Replacement {{{
--
-- Use `cn/cN` to change the word under cursor or visually selected text and then
-- repeat using . (dot) n - 1 times. We can use `n/N` to skip some replacements.
--
-- Source: http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-- }}}
--
--              ┌ populate search register with word under cursor
--              │
--              │┌ get back to where we were
--              ││
--              ││ ┌ change next occurrence of last used search pattern
--              │├┐├─┐
nnoremap("cn", "*``cgn")
nnoremap("cN", "*``cgN")

-- Similarly in Visual mode
vim.g.mc = escape [[y/\V<C-r>=escape(@", '/')<CR><CR>]]
xnoremap("cn", [[g:mc . "``cgn"]], { expr = true })
xnoremap("cN", [[g:mc . "``cgN"]], { expr = true })

-- Substitute the word on cursor or visually selected text globally
nnoremap("<Leader>su", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])
xnoremap("<leader>su", [["zy:%s/\<<C-r><C-o>"\>//g<Left><Left>]])

-- Tabs {{{2

---@param forward boolean
local function move_tabpage(forward)
  local tabpagenr = vim.api.nvim_tabpage_get_number(0)
  if forward and tabpagenr == #vim.api.nvim_list_tabpages() then
    vim.cmd "tabmove 0"
  elseif not forward and tabpagenr == 1 then
    vim.cmd "tabmove $"
  elseif forward then
    vim.cmd "tabmove +1"
  else
    vim.cmd "tabmove -1"
  end
end

-- Move the current tabpage in the forward or backward direction wrapping
-- around at the ends.
nnoremap("]t", partial(move_tabpage, true))
nnoremap("[t", partial(move_tabpage, false))

-- Tab navigation
--   - `<leader>n` goes to nth tab
--   - `<leader>0` goes to the last tab as on a normal keyboard the
--     numeric keys are from 1,2,...0.
for i = 1, 9 do
  nnoremap("<leader>" .. i, i .. "gt")
end
nnoremap("<leader>0", "<Cmd>tablast<CR>")

-- Windows {{{2

-- Toggle zoom {{{
--
-- The state is stored in a *window* variable which means each window can be
-- zoomed in and out on its own.
-- }}}
nnoremap("<leader>z", function()
  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    return
  end
  if vim.w.zoom_restore then
    vim.cmd(vim.w.zoom_restore)
    vim.w.zoom_restore = nil
  else
    vim.w.zoom_restore = vim.fn.winrestcmd()
    vim.cmd "wincmd |"
    vim.cmd "wincmd _"
  end
end)

-- Quicker window movement
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-l>", "<C-w>l")

-- Use the arrow keys to resize windows
nnoremap("<Down>", "<Cmd>resize -2<CR>")
nnoremap("<Up>", "<Cmd>resize +2<CR>")
nnoremap("<Left>", "<Cmd>vertical resize -2<CR>")
nnoremap("<Right>", "<Cmd>vertical resize +2<CR>")

-- }}}2

-- Objects {{{1

-- `il` = in line (operate on the text between first and last non-whitespace on
-- the line). Useful to copy a line and paste it characterwise (in the middle of
-- another line)
xnoremap("il", "_og_")
onoremap("il", "<Cmd>normal vil<CR>")

-- We don't need to create `al` (around line) to operate on the whole line
-- including newline, because `_` can be used instead. But still, it brings
-- consistency/symmetry.
xnoremap("al", "V")
onoremap("al", "_")

-- Entire buffer
xnoremap("ie", "gg0oG$")
--                                               get back to where we were ┐
--                                        select the entire buffer ┐       │
--                                                                 ├──┐    ├┐
onoremap("ie", ':<C-U>execute "normal! m`" <Bar> keepjumps normal! ggVG<CR>``')
--                            ├──────────┘       ├───────┘
--                            │                  └ do not update the jumplist
--                            └ store the current position to get back to

-- Terminal {{{1

-- Normal mode in terminal
tnoremap("<Esc>", [[<C-\><C-n>]])

-- Movements in terminal
-- tnoremap("<C-h>", [[<C-\><C-n><C-w>h]])
-- tnoremap("<C-j>", [[<C-\><C-n><C-w>j]])
-- tnoremap("<C-k>", [[<C-\><C-n><C-w>k]])
-- tnoremap("<C-l>", [[<C-\><C-n><C-w>l]])

-- Visual {{{1

-- Search only in Visual selection
xnoremap("/", function()
  -- If we've selected only 1 line, we probably don't want to look for a pattern;
  -- instead, we just want to extend the selection.
  if vim.fn.line "v" == vim.fn.line "." then
    return escape "/"
  end
  return escape [[<C-\><C-n>/\%V]]
end, { expr = true })

-- Repeat last edit on all the visually selected lines with dot.
xnoremap(".", ":normal! .<CR>")

-- Search for visually selected text using '*' and '#'
-- https://vim.fandom.com/wiki/Search_for_visually_selected_text#Simple
xnoremap("*", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
xnoremap("#", [[y?\V<C-R>=escape(@",'/?')<CR><CR>]])

-- Capital JK move code lines/blocks up & down (only in visual mode)
xnoremap("J", [[:move '>+1<CR>gv=gv]])
xnoremap("K", [[:move '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
xnoremap("<", "<gv")
xnoremap(">", ">gv")

-- Repeat last macro on all the visually selected lines with `@{reg}`.
xnoremap("@", [[:<C-U>execute ":* normal @".getcharstr()<CR>]], {
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
  ["I"] = { v = "<C-V>I", V = "<C-V>^o^I", [""] = "I" },
  ["A"] = { v = "<C-V>A", V = "<C-V>0o$A", [""] = "A" },
  ["gI"] = { v = "<C-V>0I", V = "<C-V>0o$I", [""] = "0I" },
}

---@param key string
---@return string
local function niceblock(key)
  local mode = vim.api.nvim_get_mode().mode
  return escape(niceblock_keys[key][mode])
end

-- Like |v_b_I|, but:
--
--   * It's available in all kinds of Visual mode.
--   * It adjusts the selected area to get intuitive result after blockwise
--     insertion if the current mode is not blockwise.
--   * In linewise Visual mode, text is inserted before the first non-blank column.
xnoremap("I", partial(niceblock, "I"), { expr = true })

-- Like |v_I|, but it's corresponding to |v_b_A| instead of |v_b_I|.
xnoremap("A", partial(niceblock, "A"), { expr = true })

-- Like |v_I|, but it behaves like |gI| in Normal mode. Text is always inserted
-- before the first column.
xnoremap("gI", partial(niceblock, "gI"), { expr = true })

-- Replace the selection without overriding the paste register and jump to the
-- end of text.
--
-- By default, `v_p` and `v_P` do the same thing, so we can remap this to `P`
-- and keep the original behavior on `p`.
xnoremap("p", '"_dP`]')

-- }}}1
