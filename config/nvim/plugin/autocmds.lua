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

do
  local timer
  local timeout = 5000

  -- Automatically clear commandline messages after a few seconds delay
  -- Source: https://unix.stackexchange.com/a/613645
  local function clear_messages()
    if timer then
      timer:stop()
    end

    timer = vim.defer_fn(function()
      if vim.fn.mode() == "n" then
        vim.api.nvim_echo({}, false, {})
      end
    end, timeout)
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
    events = { "WinEnter", "BufEnter", "InsertLeave" },
    targets = { "*" },
    command = function()
      if not vim.wo.cursorline and vim.bo.filetype ~= "dashboard" then
        vim.wo.cursorline = true
      end
    end,
  },
  {
    events = { "WinLeave", "BufLeave", "InsertEnter" },
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
      vim.cmd "tabdo wincmd ="
      vim.api.nvim_set_current_tabpage(last_tab)
    end,
  },

  -- Highlighted yank
  {
    events = { "TextYankPost" },
    targets = { "*" },
    command = function()
      vim.highlight.on_yank { higroup = "Substitute", timeout = 200 }
    end,
  },

  -- Start syncing syntax highlighting N lines before the current line
  {
    events = { "Syntax" },
    targets = { "*" },
    command = "syntax sync minlines=1000",
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
})
