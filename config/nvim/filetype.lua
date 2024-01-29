vim.filetype.add {
  extension = {
    json = 'jsonc',
    just = 'just',
    lalrpop = 'lalrpop',
    mdx = 'markdown',
    pip = 'requirements',
  },

  filename = {
    Brewfile = 'ruby',
    Justfile = 'just',
    Vagrantfile = 'ruby',
    justfile = 'just',
  },

  pattern = {
    ['.*requirements.*%.txt'] = 'requirements',
    ['.*requirements.*%.in'] = 'requirements',
  },
}
