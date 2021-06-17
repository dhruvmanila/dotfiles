require("gitsigns").setup {
  signs = {
    add = { hl = "GitSignsAdd", text = "┃" },
    change = { hl = "GitSignsChange", text = "┃" },
    delete = { hl = "GitSignsDelete", text = "_" },
    topdelete = { hl = "GitSignsDelete", text = "‾" },
    changedelete = { hl = "GitSignsChangeDelete", text = "~" },
  },
  numhl = false,
  linehl = false,
  keymaps = {
    noremap = true,
    buffer = true,

    ["n ]h"] = {
      expr = true,
      "&diff ? ']h' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
    },
    ["n [h"] = {
      expr = true,
      "&diff ? '[h' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
    },

    ["n <leader>hs"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
    ["v <leader>hs"] = '<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ["n <leader>hu"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
    ["n <leader>hr"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
    ["v <leader>hr"] = '<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ["n <leader>hR"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
    ["n <leader>hp"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
    ["n <leader>hb"] = '<cmd>lua require("gitsigns").blame_line(true)<CR>',

    -- Text objects
    ["o ih"] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
    ["x ih"] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
  },
  preview_config = {
    border = require("dm.icons").border[vim.g.border_style],
    row = 1,
    col = 1,
  },
  -- Attach to untracked files?
  attach_to_untracked = false,
}
