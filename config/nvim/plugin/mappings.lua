local escape = dm.escape
local nnoremap = dm.nnoremap
local xnoremap = dm.xnoremap
local onoremap = dm.onoremap
local cnoremap = dm.cnoremap
local inoremap = dm.inoremap
local tnoremap = dm.tnoremap

-- By using <Cmd> instead of ':', the CmdlineEnter and other related events
-- will not be triggered and thus, no need for <silent>.

-- Shortcuts for faster save and quit
--
-- '<leader>w': Save only when buffer is updated
-- '<leader>q': Save the file if modified and quit
-- 'Q': Save all changed buffers and exit vim
--
-- The reason for using <silent> instead of <Cmd> is to trigger Cmdline*
-- events so that the "write message" can be cleared.
nnoremap("<leader>w", ":update<CR>", { silent = true })
nnoremap("<leader>q", ":x<CR>", { silent = true })
nnoremap("Q", "<Cmd>xall<CR>")

-- In the terminal, `<Tab>` and `<C-i>` is seen as the same thing by Vim. To
-- avoid collision between the two keys, we will map any unused key (`<F6>`)
-- to `<C-i>` and program the terminal to send `<F6>` on `<C-i>`.
--
-- This will allow us to use `<Tab>` for toggling folds.
--
-- For kitty, it is configured in `~/config/kitty/kitty.conf`.
-- For Terminal and iTerm2, it is configured via Karabiner-elements.
nnoremap("<F6>", "<C-i>")

-- Toggle fold at current position.
nnoremap("<Tab>", "za")

-- Yank from current cursor position to the end of the line. Make it consistent
-- with the behavior of 'C', 'D'
nnoremap("Y", "y$")

do
  -- Performs either of the following tasks as per the `v:count` value:
  --   - Move the cursor based on physical lines, not the actual lines.
  --   - Store relative line number jumps in the jumplist if they exceed a threshold.
  local function jump_direction(letter)
    local jump_count = vim.v.count
    if jump_count == 0 then
      return "g" .. letter
    elseif jump_count > 5 then
      return "m'" .. jump_count .. letter
    end
    return letter
  end

  nnoremap("j", function()
    return jump_direction "j"
  end, { expr = true })
  nnoremap("k", function()
    return jump_direction "k"
  end, { expr = true })

  xnoremap("j", "gj")
  xnoremap("k", "gk")
end

-- Move to either end of the line based on physical lines, not the actual lines.
nnoremap("^", "g^")
nnoremap("0", "g0")

-- Jump to start and end of line using the home row keys
nnoremap("H", "^")
xnoremap("H", "^")
nnoremap("L", "g_")
xnoremap("L", "g_")

-- Automatically jump to the end of text on yank and paste
-- `] (backticks) to the last character of previously changed or yanked text
nnoremap("p", "p`]")
xnoremap("y", "y`]")
-- Also, replace the selection without overriding the paste register
xnoremap("p", '"_dP`]')

-- The direction of `n` and `N` depends on whether `/` or `?` was used for
-- searching forward or backward respectively.
--
-- This will make sure that `n` will always search forward and `N` backward.
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
--
-- NOTE: The '+1' is due to the fact that lua is 1-indexed.
nnoremap("n", function()
  return ({ "N", "n" })[vim.v.searchforward + 1]
end, {
  expr = true,
})
nnoremap("N", function()
  return ({ "n", "N" })[vim.v.searchforward + 1]
end, {
  expr = true,
})

-- Easy command mode if not using registers explicitly
-- nnoremap("'", ";")
-- nnoremap(";", ":")

-- Buffer management
nnoremap("]<Leader>", "<Cmd>bnext<CR>")
nnoremap("[<Leader>", "<Cmd>bprev<CR>")
nnoremap("<Leader><BS>", "<Cmd>bdelete<CR>")

-- Fast switching between last and current file
nnoremap("<Leader><Leader>", "<Cmd>buffer#<CR>")

-- Close a buffer and switching to another buffer, do not close the
-- window, see https://stackoverflow.com/q/4465095/6064933
-- nnoremap("<leader>bd", "<Cmd>bprevious <bar> bdelete #<CR>")

-- Quickfix list
nnoremap("]q", "<Cmd>cnext<CR>")
nnoremap("[q", "<Cmd>cprev<CR>")
nnoremap("]Q", "<Cmd>clast<CR>")
nnoremap("[Q", "<Cmd>cfirst<CR>")

-- Location list
nnoremap("]l", "<Cmd>lnext<CR>")
nnoremap("[l", "<Cmd>lprev<CR>")
nnoremap("]L", "<Cmd>llast<CR>")
nnoremap("[L", "<Cmd>lfirst<CR>")

-- Close location list or quickfix list if they are present,
-- Source: https://superuser.com/q/355325/736190
nnoremap("<leader>x", "<Cmd>windo lclose <bar> cclose<CR>")

-- Tab navigation
--   - `<leader>n` goes to nth tab
--   - `<leader>0` goes to the last tab as on a normal keyboard the
--     numeric keys are from 1,2,...0.
--   - `[t` and `]t` are used to move the tabs left and right respectively
nnoremap("]t", "<Cmd>+tabmove<CR>")
nnoremap("[t", "<Cmd>-tabmove<CR>")
for i = 1, 9 do
  nnoremap("<leader>" .. i, i .. "gt")
end
nnoremap("<leader>0", "<Cmd>tablast<CR>")

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

-- Don't move the cursor to the next match
nnoremap("*", "*``")
nnoremap("#", "#``")

-- Multiple Cursor Replacement
--
-- Use `cn/cN` to change the word under cursor or visually selected text and then
-- repeat using . (dot) n - 1 times. We can use `n/N` to skip some replacements.
--
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
vim.g.mc = escape [[y/\V<C-r>=escape(@", '/')<CR><CR>]]
nnoremap("cn", "*``cgn")
nnoremap("cN", "*``cgN")
xnoremap("cn", [[g:mc . "``cgn"]], { expr = true })
xnoremap("cN", [[g:mc . "``cgN"]], { expr = true })

-- Search for visually selected text using '*' and '#'
-- https://vim.fandom.com/wiki/Search_for_visually_selected_text#Simple
xnoremap("*", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
xnoremap("#", [[y?\V<C-R>=escape(@",'/?')<CR><CR>]])

-- Substitute the word on cursor or visually selected text globally
nnoremap("<Leader>su", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])
xnoremap("<leader>su", [["zy:%s/\<<C-r><C-o>"\>//g<Left><Left>]])

-- Source files (only for lua or vim files)
nnoremap("<leader>so", function()
  local filetype = vim.bo.filetype
  if filetype == "lua" or filetype == "vim" then
    vim.cmd "source %"
  end
end)

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

-- Capital JK move code lines/blocks up & down (only in visual mode)
xnoremap("J", [[:m '>+1<CR>gv=gv]])
xnoremap("K", [[:m '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
xnoremap("<", "<gv")
xnoremap(">", ">gv")

-- Repeat macros across a visual range
xnoremap(
  "@",
  [[:<C-U>execute ":'<,'>normal @".nr2char(getchar())<CR>]],
  { silent = true }
)

-- Textobjects
--
-- (a)round (l)ine: Includes newline
-- (i)nside (l)ine: No Spaces or <CR>
-- (i)nside (e)ntire: Entire object (file)
--
-- Credit: https://github.com/junegunn/dotfiles
xnoremap("al", "$o0")
onoremap("al", "<Cmd>normal val<CR>")
xnoremap("il", [[<Esc>^vg_]])
onoremap("il", [[<Cmd>normal! ^vg_<CR>]])
xnoremap("ie", "gg0oG$")
onoremap("ie", [[:<C-U>execute "normal! m`"<Bar>keepjumps normal! ggVG<CR>]])

do
  -- Returns `true` if wildmenu is active, false otherwise.
  ---@return boolean
  local function is_wildmenu()
    return vim.fn.wildmenumode() == 1
  end

  -- Make <C-p>/<C-n> as smart as <up>/<down>
  --
  -- This will either recall older/recent command-line from history, whose
  -- beginning matches the current command-line or move through the wildmenu
  -- completion.
  cnoremap("<C-p>", function()
    if is_wildmenu() then
      return escape "<C-p>"
    end
    return escape "<Up>"
  end, {
    expr = true,
  })
  cnoremap("<C-n>", function()
    if is_wildmenu() then
      return escape "<C-n>"
    end
    return escape "<Down>"
  end, {
    expr = true,
  })
end

do
  -- Return `true` if the current command-line type is search, `false` otherwise.
  ---@return boolean
  local function is_search()
    local cmdtype = vim.fn.getcmdtype()
    return cmdtype == "/" or cmdtype == "?"
  end

  -- By default, when you search for a pattern, `<C-g>` and `<C-t>` allow you
  -- to cycle through all the matches, without leaving the command-line. We remap
  -- these commands to `<Tab>` and `<S-Tab>` on the search command-line.
  --
  -- Also, pressing either of the two keys for an empty search pattern will
  -- populate the command-line with the last searched pattern.
  --
  -- Note dependency on `'wildcharm'` being set to `<C-z>` in order for this to work.
  cnoremap("<Tab>", function()
    if is_search() then
      return vim.fn.getcmdline() == "" and escape "<Up>" or escape "<C-g>"
    end
    return escape "<C-z>"
  end, {
    expr = true,
  })

  cnoremap("<S-Tab>", function()
    if is_search() then
      return vim.fn.getcmdline() == "" and escape "<Up>" or escape "<C-t>"
    end
    return escape "<S-Tab>"
  end, {
    expr = true,
  })
end

-- Make <Left>/<Right> move the cursor instead of selecting a different match
-- in the wildmenu. See :h 'wildmenu'
cnoremap("<Left>", "<Space><BS><Left>")
cnoremap("<Right>", "<Space><BS><Right>")

-- Movement in insert mode
-- inoremap("<C-h>", "<C-o>h")
-- inoremap("<C-l>", "<C-o>l")
-- inoremap("<C-j>", "<C-o>j")
-- inoremap("<C-k>", "<C-o>k")

-- Change the case for the word under cursor in insert mode
-- '<C-u>': (u)ppercase
-- '<C-t>': (t)itlecase
inoremap("<C-u>", "<esc>viwUea")
inoremap("<C-t>", "<esc>b~lea")

-- Normal mode in terminal
tnoremap("<Esc>", [[<C-\><C-n>]])

-- Movements in terminal
-- tnoremap("<C-h>", [[<C-\><C-n><C-w>h]])
-- tnoremap("<C-j>", [[<C-\><C-n><C-w>j]])
-- tnoremap("<C-k>", [[<C-\><C-n><C-w>k]])
-- tnoremap("<C-l>", [[<C-\><C-n><C-w>l]])
