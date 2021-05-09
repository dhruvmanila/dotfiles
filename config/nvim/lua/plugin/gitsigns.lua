-- Ref: https://github.com/lewis6991/gitsigns.nvim

require("gitsigns").setup({
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

    ["n ]g"] = {
      expr = true,
      "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
    },
    ["n [g"] = {
      expr = true,
      "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
    },

    ["n <leader>hs"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
    ["n <leader>hu"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
    ["n <leader>hr"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
    ["n <leader>hR"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
    ["n <leader>hp"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
    ["n <leader>hb"] = '<cmd>lua require("gitsigns").blame_line()<CR>',
    -- ['n <leader>bb'] = '<cmd>lua require("gitsigns").toggle_current_line_blame()<CR>',

    -- Text objects
    ["o ih"] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
    ["x ih"] = ':<C-U>lua require("gitsigns").select_hunk()<CR>',
  },
})
