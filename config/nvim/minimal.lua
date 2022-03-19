-- Load the 'runtime/' files
vim.cmd [[set runtimepath=$VIMRUNTIME]]

-- Originally, `packpath` contains a lot of path to search into which also
-- includes the `~/.config/nvim` directory. Now, if we open Neovim, the files
-- in the `plugin/`, `ftplugin/`, etc. directories will be loaded automatically.
--
-- We will set the value of `packpath` to contain only our testing directory to
-- avoid loading files from our config directory.
--
--     $ nvim -nu minimal.lua
vim.cmd [[set packpath=/tmp/nvim/site]]

local package_root = '/tmp/nvim/site/pack'
local packer_install_path = package_root .. '/packer/start/packer.nvim'

local function load_plugins()
  require('packer').startup {
    {
      'wbthomason/packer.nvim',
      -- Add plugins to test...
    },
    config = {
      package_root = package_root,
      compile_path = packer_install_path .. '/plugin/packer_compiled.lua',
      display = { non_interactive = true },
    },
  }
end

_G.load_config = function()
  -- Add the necessary `init.lua` settings which could include the setup
  -- functions for the plugins...
end

if vim.fn.isdirectory(packer_install_path) == 0 then
  print 'Installing plugins and dependencies...'
  vim.fn.system {
    'git',
    'clone',
    '--depth=1',
    'https://github.com/wbthomason/packer.nvim',
    packer_install_path,
  }
end

load_plugins()
require('packer').sync()
vim.cmd [[autocmd User PackerComplete ++once echo "Ready!" | lua load_config()]]
