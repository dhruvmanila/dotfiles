local map = require('core.utils').map

-- By using <Cmd> instead of ':', the CmdlineEnter and other related events
-- will not be triggered and thus, no need for <silent>.

-- 'Q' in normal mode enters Ex mode. You almost never want this.
map('n', 'Q', '<Cmd>qa<CR>')

-- Quick save
map('n', '<Leader>w', '<Cmd>w<CR>')
map('n', '<Leader>q', '<Cmd>q<CR>')
-- map('n', '<Leader>wq', ':wq<CR>')

-- Make 'Y' behave same as 'C', 'S'
map('n', 'Y', 'y$')

-- Move vertically by visual line
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- Easy command mode if not using registers explicitly
-- map('n', "'", ';')
-- map('n', ';', ':')

-- Split with Leader (same as that of tmux)
map('n', '<Leader>-', '<Cmd>sp<CR>')
map('n', '<Leader>|', '<Cmd>vsp<CR>')

-- Buffer management
map('n', ']<Leader>', '<Cmd>bnext<CR>')
map('n', '[<Leader>', '<Cmd>bprev<CR>')
map('n', '<Leader><BS>', '<Cmd>bdelete<CR>')

-- Quickfix and location list
map('n', ']q', '<Cmd>cnext<CR>')
map('n', '[q', '<Cmd>cprev<CR>')
map('n', ']Q', '<Cmd>clast<CR>')
map('n', '[Q', '<Cmd>cfirst<CR>')
-- TODO: This slows down <Leader>q
-- map('n', '<Leader>qo', '<Cmd>copen<CR>')
-- map('n', '<Leader>qc', '<Cmd>cclose<CR>')
map('n', ']l', '<Cmd>lnext<CR>')
map('n', '[l', '<Cmd>lprev<CR>')
map('n', ']L', '<Cmd>llast<CR>')
map('n', '[L', '<Cmd>lfirst<CR>')

-- Fast switching between last and current file
map('n', '<Leader><Leader>', '<C-^>')

-- Quick cd and lcd
map('n', '<Leader>cd', '<Cmd>cd %:p:h<CR>')
map('n', '<Leader>lcd', '<Cmd>lcd %:p:h<CR>')
map('n', '<Leader>tcd', '<Cmd>tcd %:p:h<CR>')

-- Quick tabs movement (trying out tabs)
map('n', '<Leader>1', '1gt')
map('n', '<Leader>2', '2gt')
map('n', '<Leader>3', '3gt')
map('n', '<Leader>4', '4gt')
map('n', '<Leader>5', '5gt')

-- Quicker window movement
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')

-- Resize window with arrow keys as I hardly need them
map('n', '<Up>', '<C-w>2+')
map('n', '<Down>', '<C-w>2-')
map('n', '<Left>', '<C-w>2<')
map('n', '<Right>', '<C-w>2>')

-- Keep the cursor at the center
-- (zt) &scrolloff lines away from the top
-- (zz) the center
map('n', '*', '*zz')
map('n', '#', '#zz')
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('n', '<C-o>', '<C-o>zz')
map('n', '<C-i>', '<C-i>zz')

-- Substitue the word on cursor globally
map('n', '<Leader>su', [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])

-- Set windows to equal width and height
map('n', '<Leader>=', '<Cmd>wincmd =<CR>')

-- Source files
map('n', '<Leader>sl', ':luafile %<CR>', {silent = true})
map('n', '<Leader>sv', ':source %<CR>', {silent = true})

-- Jump to start and end of line using the home row keys
map({'n', 'x'}, 'H', '^')
map({'n', 'x'}, 'L', '$')

-- Delete without overriding the paste register
map({'n', 'x'}, '<Leader>d', '"_d')

-- Prevent x from overriding what's in the clipboard
map({'n', 'x'}, 'x', '"_x')
map({'n', 'x'}, 'X', '"_X')

-- Replace the selection without overriding the paste register
map('x', '<Leader>p', '"_dP')

-- Capital JK move code lines/blocks up & down (only in visual mode)
map('x', 'J', [[:m '>+1<CR>gv=gv]])
map('x', 'K', [[:m '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
map('x', '<', '<gv')
map('x', '>', '>gv')

-- '*' and '#' in visual mode
map('v', '*', [["vygv:<C-U>/\<<C-R>v\><CR>]], {silent = true})
map('v', '#', [["vygv:<C-U>?\<<C-R>v\><CR>]], {silent = true})

-- Easy moving through the command history
-- <C-p>/<C-n> does the some thing, remove this?
map('c', '<C-k>', '<Up>')
map('c', '<C-j>', '<Down>')

-- Movement in insert mode
-- map('i', '<C-h>', '<C-o>h')
-- map('i', '<C-l>', '<C-o>l')
-- map('i', '<C-j>', '<C-o>j')
-- map('i', '<C-k>', '<C-o>k')

-- Normal mode in terminal
map('t', '<Esc>', [[<C-\><C-n>]])

-- Movements in terminal
-- map('t', '<C-h>', [[<C-\><C-n><C-w>h]])
-- map('t', '<C-j>', [[<C-\><C-n><C-w>j]])
-- map('t', '<C-k>', [[<C-\><C-n><C-w>k]])
-- map('t', '<C-l>', [[<C-\><C-n><C-w>l]])
