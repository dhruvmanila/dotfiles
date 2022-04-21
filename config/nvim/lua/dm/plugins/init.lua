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

-- Helper function to generate the `config` key value for plugin spec.
---@param plugin_name string
---@return string
local function conf(plugin_name)
  return ('require("dm.plugins.%s")'):format(plugin_name)
end

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
      config = conf 'completion',
      requires = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-emoji',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
      },
    }
    use { 'L3MON4D3/LuaSnip', config = conf 'luasnip' }

    -- Fuzzy finder (Telescope)
    use {
      'nvim-telescope/telescope.nvim',
      config = conf 'telescope',
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
      },
      config = conf 'dap',
      requires = {
        'mfussenegger/nvim-dap-python',
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
      },
    }
    use { 'klen/nvim-test', config = conf 'nvim_test' }

    -- Treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf 'treesitter',
      requires = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-treesitter/playground',
      },
    }
    use {
      'danymat/neogen',
      keys = {
        { 'n', '<leader>nf' }, -- Neogen func
        { 'n', '<leader>nc' }, -- Neogen class
      },
      config = conf 'neogen',
    }

    -- Tpope
    use 'tpope/vim-commentary'
    use 'tpope/vim-eunuch'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-repeat'
    use 'tpope/vim-scriptease'
    use 'tpope/vim-surround'

    -- Git
    use 'rhysd/committia.vim'
    use 'rhysd/git-messenger.vim'
    use { 'lewis6991/gitsigns.nvim', config = conf 'gitsigns' }
    use {
      'dhruvmanila/gitlinker.nvim',
      config = conf 'gitlinker',
      branch = 'fix/space-char',
    }

    -- Filetype
    use 'MTDL9/vim-log-highlighting'
    use 'fladson/vim-kitty'
    use 'raimon49/requirements.txt.vim'
    use 'vim-scripts/applescript.vim'

    -- File explorer
    use { 'tamago324/lir.nvim', keys = { { 'n', '-' } }, config = conf 'lir' }

    -- Utilities
    use 'airblade/vim-rooter'
    use 'editorconfig/editorconfig-vim'
    use 'itchyny/vim-external'
    use 'junegunn/vim-easy-align'
    use 'lambdalisue/vim-protocol'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'rcarriga/nvim-notify'
    use 'romainl/vim-cool'
    use { 'ggandor/lightspeed.nvim', config = conf 'lightspeed' }

    -- Docs
    use 'milisims/nvim-luaref'
    use 'nanotee/luv-vimdocs'

    -- Icons
    use 'yamatsum/nvim-nonicons'
    use { 'kyazdani42/nvim-web-devicons', config = conf 'nvim_web_devicons' }

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

vim.api.nvim_create_user_command(
  'PackerCompiledEdit',
  '$tabedit ' .. packer_compiled_path,
  { desc = 'Open the packer compiled file in a new tab' }
)
