dm.augroup("custom_autocmds", {
  -- Highlight current cursorline, but only in the active window and not in
  -- special buffers like dashboard.
  {
    events = { "WinEnter", "BufEnter" },
    targets = { "*" },
    command = function()
      if not vim.wo.cursorline and vim.bo.filetype ~= "dashboard" then
        vim.wo.cursorline = true
      end
    end,
  },
  {
    events = { "WinLeave", "BufLeave" },
    targets = { "*" },
    command = function()
      if vim.wo.cursorline and vim.bo.filetype ~= "dashboard" then
        vim.wo.cursorline = false
      end
    end,
  },

  -- Equalize window dimensions when resizing vim
  {
    events = { "VimResized" },
    targets = { "*" },
    command = function()
      local last_tab = vim.api.nvim_get_current_tabpage()
      vim.cmd("tabdo wincmd =")
      vim.api.nvim_set_current_tabpage(last_tab)
    end,
  },

  -- Highlighted yank
  {
    events = { "TextYankPost" },
    targets = { "*" },
    command = function()
      vim.highlight.on_yank({ higroup = "Substitute", timeout = 200 })
    end,
  },

  -- Start syncing syntax highlighting 200 lines before the current line
  {
    events = { "Syntax" },
    targets = { "*" },
    command = "syntax sync minlines=200",
  },

  -- Check if file changed (more eager than 'autoread')
  {
    events = { "FocusGained", "BufEnter" },
    targets = { "*" },
    command = "checktime",
  },

  -- Automatically go to insert mode on terminal buffer
  {
    events = { "TermOpen" },
    targets = { "*" },
    command = "startinsert",
  },
  {
    events = { "BufEnter" },
    targets = { "term://*" },
    command = "startinsert",
  },

  -- Remove trailing whitespace and lines on save
  -- TODO: autocmd or just a simple command?
  -- TODO: only for filetypes not having a formatter
  -- {
  --   events = { "BufWritePre" },
  --   targets = { "*" },
  --   command = "TrimTrailingWhitespace | TrimTrailingLines",
  -- },
})
