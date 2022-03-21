local packer_bootstrap = false
local packer_compiled_path = vim.fn.stdpath 'cache'
  .. '/packer.nvim/packer_compiled.lua'

do
  local install_path = vim.fn.stdpath 'data'
    .. '/site/pack/packer/start/packer.nvim'

  if not vim.loop.fs_stat(install_path) then
    print 'Installing packer.nvim...'
    vim.fn.system {
      'git',
      'clone',
      'https://github.com/wbthomason/packer.nvim',
      install_path,
    }
    vim.cmd 'packadd! packer.nvim'
    packer_bootstrap = true
  end
end

local packer = require 'packer'

packer.startup {
  function(use)
    use 'wbthomason/packer.nvim'

    -- LSP, completion & snippets
    use {
      'neovim/nvim-lspconfig',
      event = 'BufReadPre',
      config = "require('dm.lsp')",
      requires = {
        'b0o/SchemaStore.nvim',
        'folke/lua-dev.nvim',
      },
    }
    use {
      'hrsh7th/nvim-cmp',
      config = "require('dm.plugins.completion')",
      requires = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-emoji',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
      },
    }
    use { 'L3MON4D3/LuaSnip', config = "require('dm.plugins.luasnip')" }

    -- Fuzzy finder (Telescope)
    use {
      'nvim-telescope/telescope.nvim',
      config = "require('dm.plugins.telescope')",
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        'dhruvmanila/telescope-bookmarks.nvim',
      },
    }

    -- Debugging (DAP) & Testing
    use {
      'mfussenegger/nvim-dap',
      keys = {
        { 'n', '<F5>' }, -- continue
        { 'n', '<leader>db' }, -- toggle_breakpoint
        { 'n', '<leader>dB' }, -- set_breakpoint (with condition)
        { 'n', '<leader>dl' }, -- run_last
      },
      config = "require('dm.plugins.nvim_dap')",
      requires = {
        'mfussenegger/nvim-dap-python',
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
      },
    }

    -- Treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = "require('dm.plugins.treesitter')",
      requires = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/playground',
      },
    }

    -- Tpope
    use 'tpope/vim-commentary'
    use 'tpope/vim-eunuch'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-repeat'
    use 'tpope/vim-rhubarb'
    use 'tpope/vim-scriptease'
    use 'tpope/vim-surround'

    -- Git
    use 'rhysd/committia.vim'
    use 'rhysd/git-messenger.vim'
    use { 'lewis6991/gitsigns.nvim', config = "require('dm.plugins.gitsigns')" }

    -- Filetype
    use 'MTDL9/vim-log-highlighting'
    use 'fladson/vim-kitty'
    use 'raimon49/requirements.txt.vim'
    use 'vim-scripts/applescript.vim'

    -- File explorer
    use {
      'tamago324/lir.nvim',
      keys = '-',
      config = "require('dm.plugins.lir')",
    }

    -- Utilities
    use 'airblade/vim-rooter'
    use 'editorconfig/editorconfig-vim'
    use {
      'ggandor/lightspeed.nvim',
      config = "require('dm.plugins.lightspeed')",
    }
    use 'itchyny/vim-external'
    use 'jpalardy/vim-slime'
    use 'junegunn/vim-easy-align'
    use 'lambdalisue/vim-protocol'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'rcarriga/nvim-notify'
    use 'romainl/vim-cool'

    -- Docs
    use 'milisims/nvim-luaref'
    use 'nanotee/luv-vimdocs'

    -- Icons
    use 'kyazdani42/nvim-web-devicons'
    use 'yamatsum/nvim-nonicons'

    -- Startup & Profiling
    use 'lewis6991/impatient.nvim'
    use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }

    -- Install every package on boostrap.
    if packer_bootstrap then
      packer.sync()
    end
  end,
  log = {
    level = vim.env.DEBUG and 'debug' or 'warn',
  },
  config = {
    compile_path = packer_compiled_path,
    display = {
      open_cmd = 'silent botright 80vnew',
      prompt_border = dm.border[vim.g.border_style],
    },
    profile = {
      enable = true,
      threshold = 0, -- ms
    },
  },
}

if
  not vim.g.packer_compiled_loaded and vim.loop.fs_stat(packer_compiled_path)
then
  vim.cmd('source ' .. packer_compiled_path)
  vim.g.packer_compiled_loaded = true
end

vim.api.nvim_add_user_command(
  'PackerCompiledEdit',
  '$tabedit ' .. packer_compiled_path,
  { desc = 'Open the packer compiled file in a new tab' }
)
