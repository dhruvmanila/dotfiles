local gitsigns = require "gitsigns"

-- `on_attach` callback to setup buffer mappings for Gitsigns.
---@param bufnr number
local function on_attach(bufnr)
  local function map(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(modes, lhs, rhs, opts)
  end

  -- Navigation
  map("n", "]c", "&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>'", {
    expr = true,
  })
  map("n", "[c", "&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>'", {
    expr = true,
  })

  -- Actions
  map({ "n", "v" }, "<leader>hs", gitsigns.stage_hunk)
  map({ "n", "v" }, "<leader>hr", gitsigns.reset_hunk)
  map("n", "<leader>hu", gitsigns.undo_stage_hunk)
  map("n", "<leader>hR", gitsigns.reset_buffer)
  map("n", "<leader>hp", gitsigns.preview_hunk)

  -- Text object
  map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
end

gitsigns.setup {
  signs = {
    add = { hl = "GitSignsAdd", text = "┃" },
    change = { hl = "GitSignsChange", text = "┃" },
    delete = { hl = "GitSignsDelete", text = "_" },
    topdelete = { hl = "GitSignsDelete", text = "‾" },
    changedelete = { hl = "GitSignsChangeDelete", text = "~" },
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
