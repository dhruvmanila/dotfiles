--TODO(dhruvmanila): https://github.com/danymat/neogen/issues/83

require('neogen').setup {
  snippet_engine = 'luasnip',
  placeholders_hl = 'None',
  languages = {
    python = {
      template = {
        annotation_convention = 'numpydoc',
      },
    },
  },
}

vim.keymap.set('n', '<leader>nf', '<Cmd>Neogen func<CR>')
vim.keymap.set('n', '<leader>nc', '<Cmd>Neogen class<CR>')
