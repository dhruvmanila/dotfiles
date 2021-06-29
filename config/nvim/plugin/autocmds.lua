local o = vim.o
local fn = vim.fn
local api = vim.api

do
  -- 'colorcolumn' value for specific filetypes
  ---@type table<string, string>
  local ft_colorcolumn = { python = "88" }

  -- Set the colorcolumn value of the window appropriately.
  ---@param leaving boolean
  local function set_colorcolumn(leaving)
    if o.buftype == "prompt" then
      return
    end
    -- Don't set it when there isn't enough space or we're leaving insert mode.
    if api.nvim_win_get_width(0) <= 90 or leaving then
      o.colorcolumn = ""
    elseif o.colorcolumn == "" then
      o.colorcolumn = ft_colorcolumn[o.filetype] or "80"
    end
  end

  -- Highlight colorcolumn only in insert mode
  dm.augroup("auto_colorcolumn", {
    {
      events = "InsertEnter",
      targets = "*",
      command = function()
        set_colorcolumn(false)
      end,
    },
    {
      events = "InsertLeave",
      targets = "*",
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
      if fn.mode() == "n" then
        api.nvim_echo({}, false, {})
      end
    end, timeout)
  end

  dm.augroup("clear_command_messages", {
    {
      events = { "CmdlineLeave", "CmdlineChanged" },
      targets = ":",
      command = clear_messages,
    },
  })
end

-- Triger `autoread` when files changes on disk and notify after file change.
-- Ref: https://unix.stackexchange.com/a/383044
dm.augroup("dm__auto_reload_file", {
  {
    events = { "FocusGained", "BufEnter" },
    targets = "*",
    command = function()
      if fn.mode() ~= "c" and fn.getcmdwintype() == "" then
        vim.cmd "checktime"
      end
    end,
  },
  {
    events = "FileChangedShellPost",
    targets = "*",
    command = function()
      vim.notify(
        "[auto-reload] file changed on disk, buffer reloaded",
        vim.log.levels.WARN
      )
    end,
  },
})

dm.augroup("custom_autocmds", {
  -- Highlight current cursorline, but only in the active window and not in
  -- special buffers like dashboard.
  {
    events = { "WinEnter", "BufEnter", "InsertLeave" },
    targets = "*",
    command = function()
      if not o.cursorline and o.filetype ~= "dashboard" then
        o.cursorline = true
      end
    end,
  },
  {
    events = { "WinLeave", "BufLeave", "InsertEnter" },
    targets = "*",
    command = function()
      if o.cursorline and o.filetype ~= "dashboard" then
        o.cursorline = false
      end
    end,
  },

  -- Equalize window dimensions when resizing vim
  {
    events = "VimResized",
    targets = "*",
    command = function()
      local last_tab = api.nvim_get_current_tabpage()
      vim.cmd "tabdo wincmd ="
      api.nvim_set_current_tabpage(last_tab)
    end,
  },

  -- Highlighted yank
  {
    events = "TextYankPost",
    targets = "*",
    command = function()
      vim.highlight.on_yank { higroup = "Substitute", timeout = 200 }
    end,
  },

  -- Start syncing syntax highlighting N lines before the current line
  {
    events = "Syntax",
    targets = "*",
    command = "syntax sync minlines=1000",
  },

  -- Automatically go to insert mode on terminal buffer
  {
    events = { "TermOpen", "WinEnter" },
    targets = "term://*",
    command = "startinsert",
  },
})
