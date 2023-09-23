vim.filetype.add {
  extension = {
    just = 'just',
    json = 'jsonc',
    lalrpop = 'lalrpop',
    pip = 'requirements',
  },

  filename = {
    justfile = 'just',
    Justfile = 'just',
    Brewfile = 'ruby',
    Vagrantfile = 'ruby',
  },

  pattern = {
    ['.*requirements.*%.txt'] = 'requirements',
    ['.*requirements.*%.in'] = 'requirements',
  },
}
