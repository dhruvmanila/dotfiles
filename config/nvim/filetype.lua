vim.filetype.add {
  extension = {},

  filename = {
    Brewfile = 'ruby',
    Vagrantfile = 'ruby',
    ['.gitignore'] = 'conf',
  },

  -- Similar to |autocmd-pattern|, the file pattern is tested for a match
  -- against the file name depending on whether '/' is present or not.
  -- See `:h autocmd-pattern` for more info.
  pattern = {},
}
