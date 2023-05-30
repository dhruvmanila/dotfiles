return {
  -- Filetypes
  'MTDL9/vim-log-highlighting',
  'fladson/vim-kitty',
  'raimon49/requirements.txt.vim',
  'vim-scripts/applescript.vim',

  'tpope/vim-commentary',
  'tpope/vim-eunuch',
  'tpope/vim-repeat',
  'tpope/vim-scriptease',
  'tpope/vim-surround',

  'lambdalisue/vim-protocol',
  'rcarriga/nvim-notify',
  'romainl/vim-cool',

  { 'nacro90/numb.nvim', event = 'CmdlineEnter', config = true },

  {
    'ggandor/flit.nvim',
    keys = { { 'f' }, { 'F' }, { 't' }, { 'T' } },
    dependencies = { 'ggandor/leap.nvim' },
    config = true,
  },

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
    lazy = false,
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

  -- Icons
  'nvim-tree/nvim-web-devicons',

  -- Help docs
  'milisims/nvim-luaref',
  'nanotee/luv-vimdocs',
}
