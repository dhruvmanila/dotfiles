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

    -- Nvim Lua help
    use 'nanotee/nvim-lua-guide'

    -- Color scheme
    use {'sainnhe/gruvbox-material', config = [[require('plugin.colorscheme')]]}

    -- Helpful in visualizing colors live in the editor
    use {
      'norcalli/nvim-colorizer.lua',
      keys = {{'n', '<Leader>cc'}},
      config = function ()
        vim.api.nvim_set_keymap(
          'n', '<Leader>cc', '<Cmd>ColorizerToggle<CR>', {noremap = true}
        )
        require('colorizer').setup()
      end
    }

    -- Icons
    use {
      {
        'kyazdani42/nvim-web-devicons',
        config = [[require('plugin.nvim_web_devicons')]]
      },
      {
        'yamatsum/nvim-nonicons',
        -- config = 'vim.g.override_nvim_web_devicons = false'
      }
    }

    -- TODO: remove after #12587 is fixed (upstream bug)
    use 'antoinemadec/FixCursorHold.nvim'

    -- LSP, auto completion and related
    use {
      'kosayoda/nvim-lightbulb',
      'nvim-lua/lsp-status.nvim',
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
      {
        'liuchengxu/vista.vim',
        keys = {{'n', '<Leader>vv'}},
        config = [[require('plugin.vista')]],
      }
    }

    -- Linters and formatters (WIP plugins) (for now using efm langserver)
    use {
      {'mfussenegger/nvim-lint', config = [[require('plugin.lint')]], opt = true},
      {'lukas-reineke/format.nvim', config = [[require('plugin.format')]], opt = true}
    }

    -- Telescope and family
    use {
      "~/projects/telescope-bookmarks.nvim",
      {
        'nvim-telescope/telescope.nvim',
        config = [[require('plugin.telescope')]],
        requires = {
          {'nvim-lua/popup.nvim'},
          {'nvim-lua/plenary.nvim'},
        },
      },
      'nvim-telescope/telescope-fzy-native.nvim',
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
      {
        "nvim-telescope/telescope-arecibo.nvim",
        rocks = {
          "lua-http-parser",
          {'openssl', env = {OPENSSL_DIR='/usr/local/Cellar/openssl@1.1/1.1.1k'}}
        }
      },
    }

    -- Treesitter
    use {
      {
        'nvim-treesitter/nvim-treesitter',
        event = 'BufRead',
        run = ':TSUpdate',
        config = [[require('plugin.treesitter')]],
      },
      {
        'nvim-treesitter/playground',
        requires = 'nvim-treesitter/nvim-treesitter',
        cmd = 'TSPlaygroundToggle'
      }
    }

    -- Language specific
    use {
      'cespare/vim-toml',
      'raimon49/requirements.txt.vim',
    }

    -- Git
    use {
      {'tpope/vim-fugitive', config = [[require('plugin.fugitive')]]},
      {
        'lewis6991/gitsigns.nvim',
        event = {'BufRead', 'BufNewFile'},
        requires = 'nvim-lua/plenary.nvim',
        config = [[require('plugin.gitsigns')]],
      },
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
    -- Neovim alternative written in lua 'glepnir/dashboard-nvim'
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
