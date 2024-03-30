-- Gitsigns `on_attach` callback to setup buffer mappings.
---@param bufnr number
local function gitsigns_on_attach(bufnr)
  local gitsigns = package.loaded.gitsigns

  -- Navigation
  vim.keymap.set('n', ']c', function()
    if vim.wo.diff then
      return ']c'
    else
      vim.schedule(function()
        gitsigns.next_hunk { preview = true }
      end)
      return '<Ignore>'
    end
  end, { expr = true, desc = 'gitsigns: go to next hunk' })

  vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
      return '[c'
    else
      vim.schedule(function()
        gitsigns.prev_hunk { preview = true }
      end)
      return '<Ignore>'
    end
  end, { expr = true, desc = 'gitsigns: go to previous hunk' })

  -- Actions
  vim.keymap.set({ 'n', 'v' }, '<leader>hs', gitsigns.stage_hunk, {
    buffer = bufnr,
    desc = 'gitsigns: stage hunk',
  })
  vim.keymap.set({ 'n', 'v' }, '<leader>hr', gitsigns.reset_hunk, {
    buffer = bufnr,
    desc = 'gitsigns: reset hunk',
  })
  vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, {
    buffer = bufnr,
    desc = 'gitsigns: undo the last stage hunk',
  })
  vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, {
    buffer = bufnr,
    desc = 'gitsigns: reset buffer',
  })
  vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, {
    buffer = bufnr,
    desc = 'gitsigns: preview hunk',
  })
  vim.keymap.set('n', '<leader>hb', gitsigns.toggle_current_line_blame, {
    buffer = bufnr,
    desc = 'gitsigns: toggle current line blame',
  })
  vim.keymap.set('n', '<leader>hd', gitsigns.toggle_deleted, {
    buffer = bufnr,
    desc = 'gitsigns: toggle deleted lines',
  })

  -- Text object
  vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {
    buffer = bufnr,
  })
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
      numhl = false,
      linehl = false,
      preview_config = {
        border = dm.border,
        row = 1,
        col = 1,
      },
      attach_to_untracked = false,
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
        -- Set the default action to open the url in the browser. This function
        -- only works on macOS and Linux.
        action_callback = function(url)
          require('gitlinker.actions').open_in_browser(url)
        end,
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
