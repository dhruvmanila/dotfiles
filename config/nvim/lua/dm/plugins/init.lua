return {
  'tpope/vim-commentary',
  'tpope/vim-eunuch',
  'tpope/vim-repeat',
  'tpope/vim-scriptease',
  'tpope/vim-surround',

  'lambdalisue/vim-protocol',
  'rcarriga/nvim-notify',
  'romainl/vim-cool',

  { 'nacro90/numb.nvim', config = true },

  {
    'airblade/vim-rooter',
    init = function()
      -- Prefer using manual mode.
      vim.g.rooter_manual_only = 1

      -- Only set the current directory for the current window.
      vim.g.rooter_cd_cmd = 'lcd'

      -- These are checked breadth-first as Rooter walks up the directory tree and the
      -- first match is used.
      vim.g.rooter_patterns = { '.git', 'requirements.txt' }

      vim.g.rooter_silent_chdir = 1
      vim.g.rooter_resolve_links = 1
    end,
  },

  {
    'itchyny/vim-external',
    keys = {
      {
        '<leader>ee',
        '<Plug>(external-explorer)',
        desc = 'Open current buffer directory in finder',
      },
      { 'gx', '<Plug>(external-browser)' },
    },
    init = function()
      vim.g.external_search_engine = 'https://duckduckgo.com/?q='
    end,
  },

  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' } },
    },
  },

  {
    'yamatsum/nvim-nonicons',
    'kyazdani42/nvim-web-devicons',
    config = function()
      local nvim_web_devicons = require 'nvim-web-devicons'

      local custom_icons = {
        TelescopePrompt = {
          icon = '',
          color = '#f38019',
          name = 'TelescopePrompt',
        },
        Dashboard = {
          icon = '',
          color = '#787878',
          name = 'Dashboard',
        },
        ['[packer]'] = {
          icon = '',
          color = '#787878',
          name = 'Packer',
        },
        lir_folder_icon = {
          icon = '',
          color = '#7ebae4',
          name = 'LirFolderNode',
        },
      }

      if not nvim_web_devicons.has_loaded() then
        nvim_web_devicons.setup {
          override = custom_icons,
          default = true,
        }
      else
        nvim_web_devicons.set_icon(custom_icons)
      end
    end,
  },

  'milisims/nvim-luaref',
  'nanotee/luv-vimdocs',
}
