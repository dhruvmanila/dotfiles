-- Ref: https://github.com/liuchengxu/vista.vim
local g = vim.g

g.vista_default_executive = 'nvim_lsp'
g.vista_sidebar_width = 35
g.vista_sidebar_keepalt = 1
g.vista_echo_cursor = 0
g.vista_update_on_text_changed = 1

g.vista_executive_for = {
  markdown = 'toc',
  help = 'ctags',
}

vim.api.nvim_set_keymap('n', '<Leader>vv', '<Cmd>Vista!!<CR>', {noremap = true})
