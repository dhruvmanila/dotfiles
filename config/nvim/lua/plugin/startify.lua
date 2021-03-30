-- Ref: https://github.com/mhinz/vim-startify
local g = vim.g

vim.api.nvim_set_keymap('n', '<Leader>`', '<Cmd>Startify<CR>', {noremap = true})

-- Startify header
g.ascii_neovim = {
  '',
  '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
  '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
  '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
  '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
  '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
  '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
  '',
}

g.startify_custom_header = 'startify#pad(g:ascii_neovim + startify#fortune#boxed())'

g.startify_lists = {
  {type = 'sessions',  header = {'   Sessions'}},
  {type = 'dir',       header = {'   Current Directory ' .. vim.fn.getcwd()}},
  {type = 'files',     header = {'   Files'}},
  {type = 'bookmarks', header = {'   Bookmarks'}},
  {type = 'commands',  header = {'   Commands'}},
}

g.startify_commands = {
  {st = 'StartupTime'},
  {ps = 'PackerSync'},
  {pi = 'PackerInstall'},
  {pc = 'PackerCompile'},
}

g.startify_fortune_use_unicode = 1

-- Automatically update sessions before leaving Vim and before loading a new
-- session via :SLoad
g.startify_session_persistence = 1

-- Sort sessions by modified time instead of alphabetically
g.startify_session_sort = 1

g.startify_session_delete_buffers = 1

-- When opening a file or bookmark, do not change the PWD
g.startify_change_to_dir = 0
g.startify_change_to_vcs_root = 0
