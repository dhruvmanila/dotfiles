local o = vim.o
local fn = vim.fn
local api = vim.api
local contains = vim.tbl_contains
local augroup = dm.augroup

do
  -- 'colorcolumn' value for specific filetypes
  ---@type table<string, string>
  local ft_colorcolumn = { gitcommit = "72", python = "88" }

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
  augroup("dm__auto_colorcolumn", {
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

  augroup("dm__clear_command_messages", {
    {
      events = { "CmdlineLeave", "CmdlineChanged" },
      targets = ":",
      command = clear_messages,
    },
  })
end

-- Triger `autoread` when files changes on disk and notify after file change.
-- Ref: https://unix.stackexchange.com/a/383044
augroup("dm__auto_reload_file", {
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
      vim.notify { "Auto reload", "", "File changed on disk, buffer reloaded" }
    end,
  },
})

do
  local ignore_ft = { "dashboard", "TelescopePrompt" }

  -- Highlight current cursorline
  --   - Only in the active window
  --   - Ignore special buffers like dashboard
  --   - Disable in insert mode
  augroup("dm__auto_cursorline", {
    {
      events = { "BufEnter", "FocusGained", "InsertLeave", "WinEnter" },
      targets = "*",
      command = function()
        if not (o.cursorline or contains(ignore_ft, o.filetype)) then
          o.cursorline = true
        end
      end,
    },
    {
      events = { "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
      targets = "*",
      command = function()
        if o.cursorline and not contains(ignore_ft, o.filetype) then
          o.cursorline = false
        end
      end,
    },
  })
end

-- Enable/Disable relative number
--   - Only in the active window
--   - Ignore quickfix window
--   - Disable in insert mode
augroup("dm__auto_relative_number", {
  {
    events = { "BufEnter", "FocusGained", "InsertLeave", "WinEnter" },
    targets = "*",
    command = function()
      if o.number and o.filetype ~= "qf" then
        o.relativenumber = true
      end
    end,
  },
  {
    events = { "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
    targets = "*",
    command = function()
      if o.number and o.filetype ~= "qf" then
        o.relativenumber = false
      end
    end,
  },
})

-- Terminal autocmds
--   - Automatically go to insert mode on entering terminal
--   - Close the terminal window on exit (<C-d>)
augroup("dm__terminal", {
  {
    events = { "TermOpen", "WinEnter" },
    targets = "term://*",
    command = "startinsert",
  },
  {
    events = "TermClose",
    targets = "term://*",
    command = function()
      api.nvim_input "<CR>"
    end,
  },
})

augroup("dm__custom_autocmds", {
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

  -- When editing a file, always jump to the last known cursor position.
  -- :h last-position-jump
  {
    events = "BufReadPost",
    targets = "*",
    command = function()
      -- Cursor position when last exiting the current buffer.
      local pos = fn.line "'\""
      if o.filetype ~= "gitcommit" and pos > 0 and pos < fn.line "$" then
        vim.cmd 'keepjumps normal! g`"'
      end
    end,
  },
})
