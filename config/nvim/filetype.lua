vim.filetype.add {
  extension = {
    just = 'just',
    lalrpop = 'lalrpop',
  },

  filename = {
    justfile = 'just',
    Justfile = 'just',
    Brewfile = 'ruby',
    Vagrantfile = 'ruby',
  },

  -- Similar to |autocmd-pattern|, the file pattern is tested for a match
  -- against the file name depending on whether '/' is present or not.
  -- See `:h autocmd-pattern` for more info.
  pattern = {},
}
