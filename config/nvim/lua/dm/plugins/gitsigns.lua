local gitsigns = require 'gitsigns'

-- `on_attach` callback to setup buffer mappings for Gitsigns.
---@param bufnr number
local function on_attach(bufnr)
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

gitsigns.setup {
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
    border = dm.border[vim.g.border_style],
    row = 1,
    col = 1,
  },
  attach_to_untracked = false,
  on_attach = on_attach,
}
