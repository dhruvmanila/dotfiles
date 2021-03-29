local execute = vim.api.nvim_command
local fn = vim.fn
local map = vim.api.nvim_set_keymap

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
end

-- Some useful keybindings (PackerSync -> PackerClean + PackerUpdate)
map('n', '<Leader>ps', '<Cmd>PackerSync<CR>', {noremap = true})
map('n', '<Leader>pc', '<Cmd>PackerCompile<CR>', {noremap = true})

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

    -- Nvim Lua help
    use 'nanotee/nvim-lua-guide'

    -- Color scheme
    use {'sainnhe/gruvbox-material', config = [[require('plugin.colorscheme')]]}

    -- Helpful in visualizing colors live in the editor
    use {
      'norcalli/nvim-colorizer.lua',
      cmd = 'ColorizerToggle',
      config = [[require('colorizer').setup()]]
    }

    -- Statusline
    use {
      'glepnir/galaxyline.nvim',
      branch = 'main',
      config = [[require('plugin.statusline')]],
      after = 'gruvbox-material'
    }

    -- Icons
    use 'yamatsum/nvim-nonicons'
    use 'kyazdani42/nvim-web-devicons'

    -- LSP, auto completion and related
    use {
      {
        'neovim/nvim-lspconfig',
        event = 'BufReadPre',
        config = [[require('plugin.lspconfig')]],
      },
      {
        'hrsh7th/nvim-compe',
        event = 'InsertEnter',
        config = [[require('plugin.completion')]],
      },
    }

    -- Lsp code action indicator
    use 'kosayoda/nvim-lightbulb'

    -- Fuzzy finder
    use {
      'nvim-telescope/telescope.nvim',
      config = [[require('plugin.telescope')]],
      requires = {
        {'nvim-lua/popup.nvim'},
        {'nvim-lua/plenary.nvim'},
        {'nvim-telescope/telescope-fzy-native.nvim'}
      },
    }

    -- Treesitter
    use {
      {
        'nvim-treesitter/nvim-treesitter',
        event = 'BufRead',
        run = 'TSUpdate',
        config = [[require('plugin.treesitter')]],
      },
      {
        'nvim-treesitter/playground',
        requires = 'nvim-treesitter/nvim-treesitter',
        cmd = 'TSPlaygroundToggle'
      }
    }

    -- Git
    use {
      {
        'tpope/vim-fugitive',
        keys = {{'n', 'gs'}, {'n', '<Leader>gp'}},
        config = [[require('plugin.fugitive')]]
      },
      {
        'lewis6991/gitsigns.nvim',
        event = {'BufRead', 'BufNewFile'},
        requires = 'nvim-lua/plenary.nvim',
        config = [[require('plugin.gitsigns')]],
      }
    }

    -- Comment
    use 'tpope/vim-commentary'

    -- Pretification
    use {
      'junegunn/vim-easy-align',
      keys = {{'n', 'ge'}, {'x', 'ge'}},
      config = [[require('plugin.easy_align')]]
    }

    -- Start screen
    -- Neovim alternative written in lua
    -- use 'glepnir/dashboard-nvim'
    use {'mhinz/vim-startify', config = [[require('plugin.startify')]]}

    -- File explorer (Mainly used for going through new projects)
    use {
      'kyazdani42/nvim-tree.lua',
      requires = {'kyazdani42/nvim-web-devicons'},
      keys = {{'n', '<C-n>'}},
      config = [[require('plugin.nvim_tree')]]
    }

    -- Path navigator
    use {
      {'justinmk/vim-dirvish', config = [[require('plugin.dirvish')]]},
      {'roginfarrer/vim-dirvish-dovish', branch = 'main'}
    }

    -- Indentation tracking
    use {
      'lukas-reineke/indent-blankline.nvim',
      branch = 'lua',
      config = [[require('plugin.indentline')]]
    }

    -- Search
    use {'romainl/vim-cool', config = [[vim.g.CoolTotalMatches = 1]]}

    -- Profiling
    use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}

    -- Open external browsers, editor, finder from Neovim
    use {'itchyny/vim-external', config = [[require('plugin.vim_external')]]}
  end
}
