-- Custom pickers used in multiple parts of the config.
local M = {}

local builtin = require 'telescope.builtin'

-- What's the difference between `git_files` and `find_files`? {{{
--
-- `find_files` uses the `find(1)` command and without any options, it will
-- ignore hidden files (.*), not follow any symlinks, etc.
--
-- `git_files` uses the `git ls-files` command along with other flags to list
-- all the files tracked by `git(1)` which can include hidden files such as
-- `.editorconfig`, `.gitignore`, etc.
--
-- So, we will use `git_files` if we're in a directory tracked by `git(1)` and
-- `find_files` otherwise.
-- }}}

-- Generic picker based on whether the current directory is tracked by `git(1)`
-- or not.
function M.find_files()
  if vim.fn.isdirectory '.git' == 1 then
    builtin.git_files()
  else
    builtin.find_files()
  end
end

return M
