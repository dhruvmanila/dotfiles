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

vim.keymap.set('n', '<leader>nn', '<Cmd>Neogen<CR>')

vim.keymap.set('n', '<leader>ng', function()
  neogen.generate {
    annotation_convention = {
      python = 'google_docstrings',
    },
  }
end, { desc = 'neogen: google docstring' })
