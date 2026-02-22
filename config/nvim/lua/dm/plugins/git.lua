-- Gitsigns `on_attach` callback to setup buffer mappings.
---@param bufnr number
local function gitsigns_on_attach(bufnr)
  local gitsigns = require 'gitsigns'

  local function next_hunk()
    if vim.wo.diff then
      return ']c'
    else
      vim.schedule(function()
        gitsigns.nav_hunk('next', { preview = true }, function(err)
          if err == nil then
            dm.center_cursor()
          end
        end)
      end)
      return '<Ignore>'
    end
  end

  local function prev_hunk()
    if vim.wo.diff then
      return '[c'
    else
      vim.schedule(function()
        gitsigns.nav_hunk('prev', { preview = true }, function(err)
          if err == nil then
            dm.center_cursor()
          end
        end)
      end)
      return '<Ignore>'
    end
  end

  local mappings = {
    -- Navigation
    { 'n', ']c', next_hunk, desc = 'go to next hunk' },
    { 'n', '[c', prev_hunk, desc = 'go to previous hunk' },
    -- Actions
    { { 'n', 'v' }, '<leader>hs', gitsigns.stage_hunk, desc = 'stage hunk' },
    { { 'n', 'v' }, '<leader>hr', gitsigns.reset_hunk, desc = 'reset hunk' },
    { 'n', '<leader>hR', gitsigns.reset_buffer, desc = 'reset buffer' },
    { 'n', '<leader>hp', gitsigns.preview_hunk, desc = 'preview hunk' },
    { 'n', '<leader>hb', gitsigns.toggle_current_line_blame, 'toggle current line blame' },
    { 'n', '<leader>hd', gitsigns.preview_hunk_inline, 'toggle deleted lines' },
    -- Text object
    { { 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>' },
  }

  for _, m in ipairs(mappings) do
    vim.keymap.set(m[1], m[2], m[3], { buffer = bufnr, desc = m.desc })
  end
end

return {
  'rhysd/committia.vim',

  {
    'rhysd/git-messenger.vim',
    init = function()
      vim.g.git_messenger_always_into_popup = true
      vim.g.git_messenger_floating_win_opts = { border = dm.border }
    end,
  },

  {
    'tpope/vim-fugitive',
    keys = {
      -- 'gs' originally means goto sleep for {count} seconds which is of no use
      { 'gs', '<Cmd>Git<CR>' },
      { 'g<Space>', ':Git<Space>' },
      { '<leader>gp', '<Cmd>Git push<CR>' },
      { '<leader>gP', '<Cmd>Git push --force-with-lease<CR>' },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      preview_config = {
        border = dm.border,
        row = 1,
        col = 0,
      },
      debug_mode = dm.log.should_log(dm.log.levels.DEBUG),
      on_attach = gitsigns_on_attach,
    },
  },

  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>go', nil, mode = { 'n', 'x' } }, -- Defined by the plugin
      {
        '<leader>gr',
        function()
          require('gitlinker').get_repo_url()
        end,
        desc = 'gitlinker: open the current repository url in the browser',
      },
    },
    opts = {
      mappings = '<leader>go',
      opts = {
        add_current_line_on_normal_mode = false,
        action_callback = vim.ui.open,
        print_url = false,
      },
    },
  },

  {
    'akinsho/git-conflict.nvim',
    opts = {
      disable_diagnostics = true,
    },
  },
}
