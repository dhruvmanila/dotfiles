vim.opt.runtimepath = { vim.env.VIMRUNTIME }

-- Remove the plugin paths on non-Windows machines.
if vim.loop.os_uname().sysname ~= 'Windows_NT' then
  local homedir = vim.loop.os_homedir()
  vim.opt.packpath:remove {
    homedir .. '/.config/nvim',
    homedir .. '/.config/nvim/after',
    homedir .. '/.local/share/nvim/site',
    homedir .. '/.local/share/nvim/site/after',
  }
end

---Create a `VSCodeNotify` command call.
---@param command string
---@return string
local function VSCodeNotify(command)
  return '<Cmd>call VSCodeNotify("' .. command .. '")<CR>'
end

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options
vim.opt.clipboard:append 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.keymap.set('n', '<leader>w', '<Cmd>Write<CR>')
vim.keymap.set('n', '<leader>q', '<Cmd>Xit<CR>')

-- Jump to start (`^`) and end (`$`) of line using the home row keys.
vim.keymap.set({ 'n', 'x' }, 'H', '^')
vim.keymap.set({ 'n', 'x' }, 'L', '$')

-- Prevent 'x/X' and 'c/C' from overriding what's in the clipboard
vim.keymap.set({ 'n', 'x' }, 'x', '"_x')
vim.keymap.set({ 'n', 'x' }, 'X', '"_X')
vim.keymap.set({ 'n', 'x' }, 'c', '"_c')
vim.keymap.set({ 'n', 'x' }, 'C', '"_C')

-- Quicker window movement
vim.keymap.set('n', '<C-j>', VSCodeNotify 'workbench.action.focusBelowGroup')
vim.keymap.set('n', '<C-k>', VSCodeNotify 'workbench.action.focusAboveGroup')
vim.keymap.set('n', '<C-h>', VSCodeNotify 'workbench.action.focusLeftGroup')
vim.keymap.set('n', '<C-l>', VSCodeNotify 'workbench.action.focusRightGroup')

-- Tab movement
vim.keymap.set('n', '[t', '<Cmd>Tabprevious<CR>')
vim.keymap.set('n', ']t', '<Cmd>Tabnext<CR>')

-- Capital JK move code lines/blocks up & down (only in visual mode)
vim.keymap.set('x', 'J', [[:move '>+1<CR>gv=gv]])
vim.keymap.set('x', 'K', [[:move '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

-- Comment
vim.keymap.set({ 'x', 'n', 'o' }, 'gc', '<Plug>VSCodeCommentary')
vim.keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')

-- Git
vim.keymap.set('n', ']c', VSCodeNotify 'workbench.action.editor.nextChange')
vim.keymap.set('n', '[c', VSCodeNotify 'workbench.action.editor.previousChange')

-- LSP
vim.keymap.set({ 'n', 'x' }, 'gD', VSCodeNotify 'editor.action.revealDeclaration')
vim.keymap.set({ 'n', 'x' }, 'gr', VSCodeNotify 'editor.action.referenceSearch.trigger')
vim.keymap.set({ 'n', 'x' }, '<leader>pd', VSCodeNotify 'editor.action.peekDefinition')
vim.keymap.set({ 'n', 'x' }, '<leader>pD', VSCodeNotify 'editor.action.peekDeclaration')
vim.keymap.set('n', '<leader>rn', VSCodeNotify 'editor.action.rename')
vim.keymap.set('n', '<leader>ft', VSCodeNotify 'workbench.action.gotoSymbol')

-- Format
vim.keymap.set('n', ';f', VSCodeNotify 'editor.action.formatDocument')
