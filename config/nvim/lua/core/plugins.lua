local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
end

--[[
Notes:

A lot of the plugins will be lazy loaded on keys/commands to improve the 
startup time. There are two ways of doing this:

- Keep the plugins keymap separated in the respective plugin configuration file
which in this case will be lua/plugin/*.lua files. Add the plugin configuration
to be lazy loaded on those keys.

- Add the plugins keymap in the core/mappings.lua file which will be loaded on
startup. Add the plugin configuration to be lazy loaded on the commands to
which the keys were bound to.

--]]
return require('packer').startup {
  function(use)
    -- Packer
    use 'wbthomason/packer.nvim'

    -- Color scheme
    -- use {'sainnhe/gruvbox-material', config = [[require('plugin.colorscheme')]]}
    use {
      "npxbr/gruvbox.nvim",
      requires = {"rktjmp/lush.nvim"},
      config = [[require('plugin.colorscheme')]]
    }
    -- use {'gruvbox-community/gruvbox', config = [[require('plugin.colorscheme')]]}

    -- Treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      event = 'BufRead',
      config = [[require('plugin.treesitter')]]
    }

    -- Git
    use {
      'tpope/vim-fugitive',
      keys = {{'n', 'gs'}, {'n', '<Leader>gp'}},
      config = [[require('plugin.fugitive')]]
    }

    -- Comment
    use 'tpope/vim-commentary'

    -- Pretification
    use {
      'junegunn/vim-easy-align', 
      keys = {{'n', 'ga'}, {'x', 'ga'}},
      config = [[require('plugin.easy_align')]]
    }

    -- Start screen
    -- Neovim alternative written in lua
    -- use 'glepnir/dashboard-nvim'
    use 'mhinz/vim-startify'

    -- Indentation tracking
    use {'yggdroot/indentLine', config = [[require('plugin.indentline')]]}

    -- Search
    use {
      'romainl/vim-cool',
      keys = {'/', '?'},
      config = [[vim.g.CoolTotalMatches = 1]]
    }

    -- Profiling
    use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}

    -- Open external browsers, editor, finder from Neovim
    use {'itchyny/vim-external', config = [[require('plugin.vim_external')]]}
  end
}
