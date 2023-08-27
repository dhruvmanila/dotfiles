vim.filetype.add {
  extension = {
    just = 'just',
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
