local g = vim.g
local cmd = vim.cmd

-- Sort directories first
local dirvish_sort = ':sort ,^.*[\\/], '

-- Keep these files hidden
local dirvish_hidden_files = {
  '\\.git\\/',
  '\\.mypy_cache\\/',
  '__pycache__\\/',
  '\\.DS_Store',
}

g.dirvish_mode = dirvish_sort
  .. '| silent keeppatterns g/\\v\\/('
  .. table.concat(dirvish_hidden_files, '|')
  .. ')/d _'

-- Custom mappings are provided in after/ftplugin/dirvish.vim
g.dirvish_dovish_map_keys = 0

-- netrw similar commands just in case
cmd('command! -nargs=? -complete=dir Explore Dirvish <args>')
cmd('command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>')
cmd('command! -nargs=? -complete=dir Vexplore belowright vsplit | silent Dirvish <args>')
cmd('command! -nargs=? -complete=dir Lexplore topleft vsplit | vertical resize 30 | setlocal winfixwidth | silent Dirvish <args>')
