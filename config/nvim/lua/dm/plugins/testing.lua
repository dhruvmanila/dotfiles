return {
  {
    'klen/nvim-test',
    enabled = false,
    keys = {
      { '<leader>ti', '<Cmd>TestInfo<CR>' },
      { '<leader>tn', '<Cmd>TestNearest<CR>' },
      { '<leader>tf', '<Cmd>TestFile<CR>' },
      { '<leader>ts', '<Cmd>TestSuite<CR>' },
      { '<leader>tl', '<Cmd>TestLast<CR>' },
    },
    opts = {
      silent = true,
      termOpts = {
        direction = 'horizontal',
        go_back = true,
        stopinsert = true,
        height = math.floor(vim.o.lines * 0.4),
        width = math.floor(vim.o.columns * 0.4),
      },
    },
  },
}
