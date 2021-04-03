-- vim.g.format_debug = true

require('format').setup {
  ['python'] = {
    {cmd = {"black --quiet", "isort --profile=black"}}
  }
}

vim.api.nvim_set_keymap('n', '<Leader>ff', '<Cmd>Format<CR>', {noremap = true})
