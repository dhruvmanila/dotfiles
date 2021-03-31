local g = vim.g
local cmd = vim.cmd

-- Sort by directory first
g.dirvish_mode = [[:sort ,^.*[\/],]]

-- Custom mappings are provided in after/ftplugin/dirvish.vim
g.dirvish_dovish_map_keys = 0

-- netrw similar commands just in case
cmd [[command! -nargs=? -complete=dir Explore Dirvish <args>]]
cmd [[command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>]]
cmd [[command! -nargs=? -complete=dir Vexplore belowright vsplit | silent Dirvish <args>]]
cmd [[command! -nargs=? -complete=dir Lexplore topleft vsplit | vertical resize 30 | setlocal winfixwidth | silent Dirvish <args>]]
