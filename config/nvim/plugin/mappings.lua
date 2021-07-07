local map = require("dm.utils").map

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
map("n", "<Leader>w", ":update<CR>", { silent = true })
map("n", "<Leader>q", ":x<CR>", { silent = true })
map("n", "Q", "<Cmd>xall<CR>")

-- Yank from current cursor position to the end of the line. Make it consistent
-- with the behavior of 'C', 'D'
map("n", "Y", "y$")

-- Move the cursor based on physical lines, not the actual lines.
map("n", "j", [[ (v:count == 0 ? 'gj' : 'j') ]], { expr = true })
map("n", "k", [[ (v:count == 0 ? 'gk' : 'k') ]], { expr = true })
map("n", "^", "g^")
map("n", "0", "g0")
map("x", "j", "gj")
map("x", "k", "gk")

-- Jump to start and end of line using the home row keys
map({ "n", "x" }, "H", "^")
map({ "n", "x" }, "L", "g_")

-- Automatically jump to the end of text on yank and paste
-- ` (backticks) to the last character of previously changed or yanked text
map("n", "p", "p`]")
map("x", "p", "p`]")
map("x", "y", "y`]")

-- Easy command mode if not using registers explicitly
-- map('n', "'", ';')
-- map('n', ';', ':')

-- Buffer management
map("n", "]<Leader>", "<Cmd>bnext<CR>")
map("n", "[<Leader>", "<Cmd>bprev<CR>")
map("n", "<Leader><BS>", "<Cmd>bdelete<CR>")

-- Quickfix list
map("n", "]q", "<Cmd>cnext<CR>")
map("n", "[q", "<Cmd>cprev<CR>")
map("n", "]Q", "<Cmd>clast<CR>")
map("n", "[Q", "<Cmd>cfirst<CR>")

-- Location list
map("n", "]l", "<Cmd>lnext<CR>")
map("n", "[l", "<Cmd>lprev<CR>")
map("n", "]L", "<Cmd>llast<CR>")
map("n", "[L", "<Cmd>lfirst<CR>")

-- Fast switching between last and current file
map("n", "<Leader><Leader>", "<Cmd>buffer#<CR>")

-- Tabs
map("n", "]t", "<Cmd>tabnext<CR>")
map("n", "[t", "<Cmd>tabprev<CR>")
-- `<leader>n` goes to nth tab
for i = 1, 9 do
  map("n", "<leader>" .. i, i .. "gt")
end
map("n", "<leader>0", "<Cmd>tablast<CR>")

-- Quicker window movement
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")

-- Use alt + hjkl to resize windows
map("n", "<M-j>", "<Cmd>resize -2<CR>")
map("n", "<M-k>", "<Cmd>resize +2<CR>")
map("n", "<M-h>", "<Cmd>vertical resize -2<CR>")
map("n", "<M-l>", "<Cmd>vertical resize +2<CR>")

-- Keep the cursor at the center
-- (``) don't move the cursor to the next match
map("n", "*", "*``")
map("n", "#", "#``")

-- Search for visually selected text using '*' and '#'
-- https://vim.fandom.com/wiki/Search_for_visually_selected_text#Simple
map("x", "*", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])
map("x", "#", [[y?\V<C-R>=escape(@",'/?')<CR><CR>]])

-- Substitute the word on cursor globally
map("n", "<Leader>su", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])

-- Source files (works only with either lua or vim files)
map("n", "<leader>so", ":source %<CR>", { silent = true })

-- Delete without overriding the paste register
map({ "n", "x" }, "<Leader>d", '"_d')

-- Prevent 'x/X' and 'c/C' from overriding what's in the clipboard
map({ "n", "x" }, "x", '"_x')
map({ "n", "x" }, "X", '"_X')
map({ "n", "x" }, "c", '"_c')
map({ "n", "x" }, "C", '"_C')

-- Replace the selection without overriding the paste register
map("x", "p", '"_dP')

-- Capital JK move code lines/blocks up & down (only in visual mode)
map("x", "J", [[:m '>+1<CR>gv=gv]])
map("x", "K", [[:m '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Easy moving through the command history
-- <C-p>/<C-n> does the some thing, remove this?
map("c", "<C-k>", "<Up>")
map("c", "<C-j>", "<Down>")

-- Movement in insert mode
-- map('i', '<C-h>', '<C-o>h')
-- map('i', '<C-l>', '<C-o>l')
-- map('i', '<C-j>', '<C-o>j')
-- map('i', '<C-k>', '<C-o>k')

-- Change the case for the word under cursor in insert mode
-- '<C-u>': (u)ppercase
-- '<C-t>': (t)itlecase
map("i", "<C-u>", "<esc>viwUea")
map("i", "<C-t>", "<esc>b~lea")

-- Normal mode in terminal
map("t", "<Esc>", [[<C-\><C-n>]])

-- Movements in terminal
-- map('t', '<C-h>', [[<C-\><C-n><C-w>h]])
-- map('t', '<C-j>', [[<C-\><C-n><C-w>j]])
-- map('t', '<C-k>', [[<C-\><C-n><C-w>k]])
-- map('t', '<C-l>', [[<C-\><C-n><C-w>l]])
