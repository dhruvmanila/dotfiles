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
    'https://codeberg.org/andyg/leap.nvim',
    keys = { { 'f' }, { 'F' }, { 't' }, { 'T' } },
    config = function()
      -- Ref: https://codeberg.org/andyg/leap.nvim#search-and-motions
      local function as_ft(key_specific_args)
        local common_args = {
          inputlen = 1,
          inclusive = true,
          -- To limit search scope to the current line:
          -- pattern = function (pat) return '\\%.l'..pat end,
          opts = {
            labels = '', -- force autojump
            safe_labels = vim.fn.mode(1):match '[no]' and '' or nil, -- [1]
          },
        }
        return vim.tbl_deep_extend('keep', common_args, key_specific_args)
      end

      local clever = require('leap.user').with_traversal_keys -- [2]
      local clever_f = clever('f', 'F')
      local clever_t = clever('t', 'T')

      for key, key_specific_args in pairs {
        f = { opts = clever_f },
        F = { backward = true, opts = clever_f },
        t = { offset = -1, opts = clever_t },
        T = { backward = true, offset = 1, opts = clever_t },
      } do
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          require('leap').leap(as_ft(key_specific_args))
        end)
      end

      -- [1] Match the modes here for which you don't want to use labels
      --     (`:h mode()`, `:h lua-pattern`).
      -- [2] This helper function makes it easier to set "clever-f"-like functionality
      --     (https://github.com/rhysd/clever-f.vim), returning an `opts` table derived from the
      --     defaults, where the given keys are added to `keys.next_target` and `keys.prev_target`
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
}
