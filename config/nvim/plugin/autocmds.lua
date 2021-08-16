local o = vim.o
local fn = vim.fn
local api = vim.api
local augroup = dm.augroup

-- Clear command-line messages {{{1

do
  local timer
  local timeout = 5000

  -- Automatically clear command-line messages after a few seconds delay
  -- Source: https://unix.stackexchange.com/a/613645
  augroup("dm__clear_cmdline_messages", {
    {
      events = "CmdlineLeave",
      targets = ":",
      command = function()
        if timer then
          timer:stop()
        end
        timer = vim.defer_fn(function()
          if fn.mode() == "n" then
            api.nvim_echo({}, false, {})
          end
        end, timeout)
      end,
    },
  })
end

-- Highlighted yank {{{1

augroup("dm__highlighted_yank", {
  {
    events = "TextYankPost",
    targets = "*",
    command = function()
      vim.highlight.on_yank { higroup = "Substitute", timeout = 200 }
    end,
  },
})

-- Reload file when modified outside Vim {{{1

-- When does Vim check whether a file has been changed outside the current instance? {{{
--
-- In the terminal, when you:
--
--    - try to write the buffer
--    - execute a shell command
--    - execute `:checktime`
--
-- Also when you give the focus to a Vim instance where the file is loaded; but
-- only in the GUI, or in a terminal which supports the focus event tracking
-- feature. For `tmux`, the `focus-events` option needs to be turned on.
-- }}}
augroup("dm__auto_reload_file", {
  {
    events = {
      "BufEnter",
      "CursorHold",
    },
    targets = "*",
    command = function()
      local bufnr = tonumber(fn.expand "<abuf>")
      local name = api.nvim_buf_get_name(bufnr)
      if
        name == ""
        -- Only check for normal files
        or vim.bo[bufnr].buftype ~= ""
        -- To avoid: E211: File "..." no longer available
        or not fn.filereadable(name)
      then
        return
      end
      -- What does it do? {{{
      --
      -- Check whether the current file has been modified outside of Vim. If it
      -- has, Vim will automatically re-read it because we've set 'autoread'.
      --
      -- A modification does not necessarily involve the *contents* of the file.
      -- Changing its *permissions* is *also* a modification.
      --
      -- Ref: https://unix.stackexchange.com/a/383044
      -- }}}
      -- Why `bufnr`? {{{
      --
      -- This function will be called frequently, and if we have many buffers,
      -- without specifiying a buffer, Vim would check *all* buffers. This could
      -- be too time-consuming.
      -- }}}
      vim.cmd(bufnr .. "checktime")
    end,
  },
})

-- Restore cursor to last position {{{1

-- When editing a file, always jump to the last known cursor position.
-- Source: `:h last-position-jump`
augroup("dm__restore_cursor", {
  {
    events = "BufReadPost",
    targets = "*",
    command = function()
      -- Cursor position when last exiting the current buffer.
      -- See :h 'quote
      local line, col = unpack(api.nvim_buf_get_mark(0, '"'))
      if
        o.filetype ~= "gitcommit"
        and line > 0
        and line < api.nvim_buf_line_count(0)
      then
        api.nvim_win_set_cursor(0, { line, col })
      end
    end,
  },
})

-- Set 'colorcolumn' {{{1

do
  -- 'colorcolumn' value for specific filetypes
  local ft_colorcolumn = {
    gitcommit = "72",
    python = "88",
  }

  ---@param leaving boolean indicating whether we are leaving insert mode
  local function set_colorcolumn(leaving)
    if leaving or o.buftype == "prompt" then
      o.colorcolumn = ""
    elseif o.colorcolumn == "" then
      o.colorcolumn = ft_colorcolumn[o.filetype] or "80"
    end
  end

  augroup("dm__auto_colorcolumn", {
    {
      events = "InsertEnter",
      targets = "*",
      command = set_colorcolumn,
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

-- Set 'cursorline' {{{1

-- `'cursorline'` only in the active window and not in insert mode.

do
  -- When the cursor is on a long soft-wrapped line, and we enable 'cursorline',
  -- we want only the current *screen* line to be highlighted, not the whole
  -- *text* line.
  local cursorlineopt_save = o.cursorlineopt

  ---@param leaving boolean indicating whether we are leaving insert mode
  local function set_cursorline(leaving)
    if leaving and o.buftype ~= "prompt" then
      if o.filetype ~= "dashboard" then
        o.cursorline = true
        o.cursorlineopt = "screenline,number"
      end
    else
      o.cursorline = false
      o.cursorlineopt = cursorlineopt_save
    end
  end

  -- Do NOT include `FocusGained`/`FocusLost` events {{{
  --
  -- When getting the focus back to Neovim while in terminal mode, the cursor
  -- disppears as it is trying to set the cursorline. If we include `terminal`
  -- filetype in `ignore_ft`, then the cursorline won't be set while scrolling
  -- through the output in the terminal.
  --
  -- It's weird that Vim exhibits a different behavior in that it does not
  -- *display* the cursorline while in terminal mode. The cursorline is set, but
  -- it is not displayed.
  --
  -- https://github.com/neovim/neovim/issues/15355
  -- }}}
  -- Why both `Buf*` and `Win*` events? {{{
  --
  -- Open a buffer (<file1>) and then open another buffer using `:split <file2>`.
  -- You will see that the cursorline gets set in both windows. But, when you
  -- move the cursor back and forth between windows, the original behavior is back.
  --
  -- Looking at the autocmd logs:
  --
  --   > WinLeave <file1>  <-- This is where we should set nocursorline
  --   > WinEnter <file1>
  --   > ...
  --   > BufLeave <file1>  <-- This is where we are actually setting it
  --   > BufEnter <file2>
  --
  -- As cursorline is a window option, we need to set the option *before* leaving
  -- the window. If we set the option only on `BufLeave`, it won't affect the
  -- window. The same can be explained for `*Enter` events.
  -- }}}
  augroup("dm__auto_cursorline", {
    {
      events = {
        "BufEnter",
        "InsertLeave",
        "WinEnter",
      },
      targets = "*",
      command = function()
        set_cursorline(true)
      end,
    },
    {
      events = {
        "BufLeave",
        "InsertEnter",
        "WinLeave",
      },
      targets = "*",
      command = set_cursorline,
    },
  })
end

-- Set 'relativenumber' {{{1

-- What does it do? {{{
--
-- Enable/Disable relative number:
--   - Only in the active window
--   - Ignore quickfix window
--   - Disable in insert mode
-- }}}
augroup("dm__auto_relative_number", {
  {
    events = {
      "BufEnter",
      "FocusGained",
      "InsertLeave",
      "WinEnter",
    },
    targets = "*",
    command = function()
      if o.number and o.filetype ~= "qf" then
        o.relativenumber = true
      end
    end,
  },
  {
    events = {
      "BufLeave",
      "FocusLost",
      "InsertEnter",
      "WinLeave",
    },
    targets = "*",
    command = function()
      if o.number and o.filetype ~= "qf" then
        o.relativenumber = false
      end
    end,
  },
})

-- Terminal {{{1

augroup("dm__terminal", {
  {
    events = {
      "TermOpen",
      "WinEnter",
    },
    targets = "term://*",
    command = "startinsert",
  },
  {
    events = "TermClose",
    targets = "term://*",
    command = function()
      -- Avoid the annoying '[Process exited 0]' prompt
      api.nvim_input "<CR>"
    end,
  },
})

-- VimResized {{{1

augroup("dm__vim_resized", {
  {
    events = "VimResized",
    targets = "*",
    command = function()
      local last_tab = api.nvim_get_current_tabpage()
      vim.cmd "tabdo wincmd ="
      api.nvim_set_current_tabpage(last_tab)
    end,
  },
  {
    events = {
      "VimEnter",
      "VimResized",
    },
    targets = "*",
    command = function()
      o.previewheight = math.floor(o.lines / 3)
    end,
  },
})
