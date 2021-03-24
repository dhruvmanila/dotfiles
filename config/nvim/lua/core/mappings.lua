local map = require('core.utils').map

-- By using <Cmd> instead of ':', the CmdlineEnter and other related events
-- will not be triggered and thus, no need for <silent>.

-- 'Q' in normal mode enters Ex mode. You almost never want this.
map('n', 'Q', '<Cmd>qa<CR>')

-- Quick save
map('n', '<Leader>w', '<Cmd>w<CR>')
map('n', '<Leader>q', '<Cmd>q<CR>')
-- map('n', '<Leader>wq', ':wq<CR>')

-- Move vertically by visual line
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- Jump to start and end of line using the home row keys
map('', 'H', '^')
map('', 'L', '$')

-- Split with Leader (same as that of tmux)
map('n', '<Leader>-', '<Cmd>sp<CR>')
map('n', '<Leader>|', '<Cmd>vsp<CR>')

-- Buffer management
map('n', ']<Leader>', '<Cmd>bnext<CR>')
map('n', '[<Leader>', '<Cmd>bprev<CR>')
map('n', '<Leader><BS>', '<Cmd>bdelete<CR>')

-- Fast switching between last and current file
map('n', '<Leader><Leader>', '<C-^>')

-- Quicker window movement
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')

-- Resize window with arrow keys as I hardly need them
map('n', '<Up>', '<C-w>5+')
map('n', '<Down>', '<C-w>5-')
map('n', '<Left>', '<C-w>5<')
map('n', '<Right>', '<C-w>5>')

-- Easy moving through the command history
-- <C-p>/<C-n> does the some thing, remove this?
map('c', '<C-k>', '<Up>')
map('c', '<C-j>', '<Down>')

-- Capital JK move code lines/blocks up & down (only in visual mode)
map('x', 'J', [[:m '>+1<CR>gv=gv]])
map('x', 'K', [[:m '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
map('x', '<', '<gv')
map('x', '>', '>gv')

-- Movement in insert mode
map('i', '<C-h>', '<C-o>h')
map('i', '<C-l>', '<C-o>l')
map('i', '<C-j>', '<C-o>j')
map('i', '<C-k>', '<C-o>k')

-- Replace the selection without overriding the paste register
map('x', 'p', '"_dP')

-- Make 'Y' behave same as 'C', 'S'
map('n', 'Y', 'y$')

-- Delete without overriding the paste register
map({'n', 'v'}, '<Leader>d', '"_d')

-- Prevent x from overriding what's in the clipboard
map({'n', 'v'}, 'x', '"_x')
map({'n', 'v'}, 'X', '"_X')

-- Keep the cursor at
-- (zt) &scrolloff lines away from the top
-- (zz) the center
map('n', '*', '*zz')
map('n', '#', '#zz')
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('n', '<C-o>', '<C-o>zz')
map('n', '<C-i>', '<C-i>zz')

-- Substitue the word on cursor globally
map('n', '<Leader>s', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])

-- Set windows to equal width and height
-- TODO: Maybe use custom function which only sets equal width
map('n', '<Leader>=', '<Cmd>wincmd =<CR>')

-- Source files
map('n', '<Leader>sl', ':luafile %<CR>', {silent = true})
map('n', '<Leader>sv', ':source %<CR>', {silent = true})
