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
  end, { expr = true })

  vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
      return '[c'
    else
      vim.schedule(function()
        gitsigns.prev_hunk { preview = true }
      end)
      return '<Ignore>'
    end
  end, { expr = true })

  -- Actions
  vim.keymap.set({ 'n', 'v' }, '<leader>hs', gitsigns.stage_hunk, {
    buffer = bufnr,
    desc = 'Gitsigns: Stage hunk',
  })
  vim.keymap.set({ 'n', 'v' }, '<leader>hr', gitsigns.reset_hunk, {
    buffer = bufnr,
    desc = 'Gitsigns: Reset hunk',
  })
  vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, {
    buffer = bufnr,
    desc = 'Gitsigns: Undo stage hunk',
  })
  vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, {
    buffer = bufnr,
    desc = 'Gitsigns: Reset buffer',
  })
  vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, {
    buffer = bufnr,
    desc = 'Gitsigns: Preview hunk',
  })

  -- Text object
  vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {
    buffer = bufnr,
  })
end

gitsigns.setup {
  signs = {
    add = { hl = 'GitSignsAdd', text = '┃' },
    change = { hl = 'GitSignsChange', text = '┃' },
    delete = { hl = 'GitSignsDelete', text = '_' },
    topdelete = { hl = 'GitSignsDelete', text = '‾' },
    changedelete = { hl = 'GitSignsChangeDelete', text = '~' },
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
