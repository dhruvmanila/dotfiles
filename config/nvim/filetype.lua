vim.filetype.add {
  extension = {
    just = 'just',
    lalrpop = 'lalrpop',
    mdx = 'markdown',
    pip = 'requirements',
  },

  filename = {
    Brewfile = 'ruby',
    Justfile = 'just',
    Vagrantfile = 'ruby',
    ['uv.lock'] = 'toml',
    justfile = 'just',
  },

  pattern = {
    ['.*/%.?vscode/settings.json'] = 'jsonc',
    ['.*/zed/settings.json'] = 'jsonc',
    ['.*/work/astral/.*%.snap'] = 'markdown',
    ['.*requirements.*%.in'] = 'requirements',
    ['.*requirements.*%.txt'] = 'requirements',
  },
}
