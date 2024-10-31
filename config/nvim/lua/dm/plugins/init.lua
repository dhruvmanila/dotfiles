return {
  -- Filetypes
  'MTDL9/vim-log-highlighting',
  'fladson/vim-kitty',
  'vim-scripts/applescript.vim',

  'tpope/vim-eunuch',
  'tpope/vim-repeat',
  'tpope/vim-scriptease',
  'tpope/vim-surround',

  'lambdalisue/vim-protocol',
  'romainl/vim-cool',

  { 'nacro90/numb.nvim', event = 'CmdlineEnter', config = true },

  {
    'ggandor/flit.nvim',
    keys = { { 'f' }, { 'F' }, { 't' }, { 'T' } },
    dependencies = { 'ggandor/leap.nvim' },
    config = true,
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
}
