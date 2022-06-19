-- TODO: Is it possible to make a nvim-cmp extension to provide completion
-- when required for generating docstrings?

local neogen = require 'neogen'

neogen.setup {
  snippet_engine = 'luasnip',
  placeholders_hl = 'None',
  languages = {
    python = {
      template = {
        -- Update the default annotation convention.
        annotation_convention = 'numpydoc',
      },
    },
  },
}

vim.keymap.set('n', '<leader>nf', '<Cmd>Neogen func<CR>')
vim.keymap.set('n', '<leader>nc', '<Cmd>Neogen class<CR>')

vim.keymap.set('n', '<leader>ngf', function()
  neogen.generate {
    annotation_convention = {
      python = 'google_docstrings',
    },
    type = 'func',
  }
end, { desc = 'neogen: google docstring for function' })

vim.keymap.set('n', '<leader>ngc', function()
  neogen.generate {
    annotation_convention = {
      python = 'google_docstrings',
    },
    type = 'class',
  }
end, { desc = 'neogen: google docstring for class' })
