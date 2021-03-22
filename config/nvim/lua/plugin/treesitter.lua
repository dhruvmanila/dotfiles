-- Ref: https://github.com/nvim-treesitter/nvim-treesitter

require('nvim-treesitter.configs').setup {
  -- one of 'all', 'language', or a list of languages
  ensure_installed = {
    'bash', 'json', 'lua', 'python', 'regex', 'ruby', 'toml'
  },

  -- syntax highlighting
  highlight = {enable = true}
}
