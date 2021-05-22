do
  -- 'colorcolumn' value for specific filetypes
  ---@type table<string, string>
  local ft_colorcolumn = { python = "88" }

  -- Set the colorcolumn value of the window appropriately.
  ---@param leaving boolean
  local function set_colorcolumn(leaving)
    if vim.bo.buftype == "prompt" then
      return
    end
    -- Don't set it when there isn't enough space or we're leaving insert mode.
    if vim.api.nvim_win_get_width(0) <= 90 or leaving then
      vim.wo.colorcolumn = ""
    elseif vim.wo.colorcolumn == "" then
      vim.wo.colorcolumn = ft_colorcolumn[vim.bo.filetype] or "80"
    end
  end

  -- Highlight colorcolumn only in insert mode
  dm.augroup("auto_colorcolumn", {
    {
      events = { "InsertEnter" },
      targets = { "*" },
      command = function()
        set_colorcolumn(false)
      end,
    },
    {
      events = { "InsertLeave" },
      targets = { "*" },
      command = function()
        set_colorcolumn(true)
      end,
    },
  })
end

-- Automatically clear commandline messages after a few seconds delay
-- Source: https://unix.stackexchange.com/a/613645
do
  local id

  -- Stop the old timer, if any, and create a new timer to clear out the
  -- command line messages.
  local function clear_messages()
    if id then
      vim.fn.timer_stop(id)
    end
    id = vim.fn.timer_start(2000, function()
      if vim.fn.mode() == "n" then
        vim.api.nvim_echo({}, false, {})
      end
    end)
  end

  dm.augroup("clear_command_messages", {
    {
      events = { "CmdlineLeave", "CmdlineChanged" },
      targets = { ":" },
      command = clear_messages,
    },
  })
end

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
    events = { "TermOpen", "WinEnter" },
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
