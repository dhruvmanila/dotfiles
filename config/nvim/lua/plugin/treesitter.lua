-- Ref: https://github.com/nvim-treesitter/nvim-treesitter
local map = vim.api.nvim_set_keymap

map('n', '<Leader>tp', '<Cmd>TSPlaygroundToggle<CR>', {noremap = true})

require('nvim-treesitter.configs').setup {
  -- one of 'all', 'language', or a list of languages
  ensure_installed = {
    'bash', 'json', 'lua', 'python', 'query', 'regex', 'ruby', 'toml'
  },

  -- syntax highlighting
  highlight = {
    enable = true,
    custom_captures = {
      ["docstring"] = "TSComment",
    },
  },
}
