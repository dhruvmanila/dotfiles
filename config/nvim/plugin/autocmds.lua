local o = vim.o
local fn = vim.fn
local api = vim.api
local nvim_create_augroup = api.nvim_create_augroup
local nvim_create_autocmd = api.nvim_create_autocmd

-- Clear command-line messages {{{1

do
  local timer
  local timeout = 5000

  -- Automatically clear command-line messages after a few seconds delay
  -- Source: https://unix.stackexchange.com/a/613645
  nvim_create_autocmd('CmdlineLeave', {
    group = nvim_create_augroup('dm__clear_cmdline_messages', { clear = true }),
    pattern = ':',
    callback = function()
      if timer then
        timer:stop()
      end
      timer = vim.defer_fn(function()
        if fn.mode() == 'n' then
          api.nvim_echo({}, false, {})
        end
      end, timeout)
    end,
    desc = ('Clear command-line messages after %d seconds'):format(timeout / 1000),
  })
end

-- Highlighted yank {{{1

nvim_create_autocmd('TextYankPost', {
  group = nvim_create_augroup('dm__highlighted_yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = 'Substitute', timeout = 200 }
  end,
  desc = 'Highlight a selection on yank',
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
nvim_create_autocmd({ 'BufEnter', 'CursorHold' }, {
  group = nvim_create_augroup('dm__auto_reload_file', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local name = api.nvim_buf_get_name(bufnr)
    if
      name == ''
      -- Only check for normal files
      or vim.bo[bufnr].buftype ~= ''
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
    vim.cmd(bufnr .. 'checktime')
  end,
  desc = 'Reload file when modified outside Neovim',
})

-- Restore cursor to last position {{{1

-- When editing a file, always jump to the last known cursor position.
-- Source: `:h last-position-jump`
nvim_create_autocmd('BufReadPost', {
  group = nvim_create_augroup('dm__restore_cursor', { clear = true }),
  callback = function()
    -- Cursor position when last exiting the current buffer.
    ---@see :h 'quote
    local line, col = unpack(api.nvim_buf_get_mark(0, '"'))
    if o.filetype ~= 'gitcommit' and line > 0 and line < api.nvim_buf_line_count(0) then
      api.nvim_win_set_cursor(0, { line, col })
    end
  end,
  desc = 'Restore cursor to the last position',
})

-- Set 'colorcolumn' {{{1

do
  -- 'colorcolumn' value for specific filetypes
  local ft_colorcolumn = {
    gitcommit = '72',
    python = '88',
  }

  ---@param leaving boolean indicating whether we are leaving insert mode
  local function set_colorcolumn(leaving)
    if leaving or o.buftype == 'prompt' then
      o.colorcolumn = ''
    elseif o.colorcolumn == '' then
      o.colorcolumn = ft_colorcolumn[o.filetype] or '80'
    end
  end

  local id = nvim_create_augroup('dm__auto_colorcolumn', { clear = true })

  nvim_create_autocmd('InsertEnter', {
    group = id,
    callback = function()
      set_colorcolumn(false)
    end,
    desc = 'Set colorcolumn',
  })

  nvim_create_autocmd('InsertLeave', {
    group = id,
    callback = function()
      set_colorcolumn(true)
    end,
    desc = 'Unset colorcolumn',
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
    if leaving and o.buftype ~= 'prompt' then
      if o.filetype ~= 'dashboard' then
        o.cursorline = true
        o.cursorlineopt = 'screenline,number'
      end
    else
      o.cursorline = false
      o.cursorlineopt = cursorlineopt_save
    end
  end

  local id = nvim_create_augroup('dm__auto_cursorline', { clear = true })

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
  nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'WinEnter' }, {
    group = id,
    callback = function()
      set_cursorline(true)
    end,
    desc = 'Unset cursorline',
  })
  nvim_create_autocmd({ 'BufLeave', 'InsertEnter', 'WinLeave' }, {
    group = id,
    callback = function()
      set_cursorline(false)
    end,
    desc = 'Set cursorline',
  })
end

-- Set 'relativenumber' {{{1

-- Enable/Disable relative number:
--   - Only in the active window
--   - Ignore quickfix window
--   - Disable in insert mode

do
  -- Flag to denote the current state of auto relative number.
  local auto_relative_number = false

  -- Create the autocmds necessary for auto `relativenumber`.
  ---@param group integer|string
  local function create_autocmds(group)
    nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
      group = group,
      callback = function()
        if o.number and o.filetype ~= 'qf' then
          o.relativenumber = true
        end
      end,
      desc = 'Set relativenumber',
    })

    nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
      group = group,
      callback = function()
        if o.number and o.filetype ~= 'qf' then
          o.relativenumber = false
        end
      end,
      desc = 'Unset relativenumber',
    })
  end

  -- Toggle between the two states of auto relative number.
  ---@param notify? boolean (default: true)
  local function toggle_auto_relative_number(notify)
    notify = vim.F.if_nil(notify, true)
    auto_relative_number = not auto_relative_number
    local group = nvim_create_augroup('dm__auto_relative_number', {
      clear = true,
    })
    if auto_relative_number then
      if notify then
        dm.notify('Autocmds', 'Auto `relativenumber` turned ON')
      end
      o.relativenumber = true
      create_autocmds(group)
    else
      if notify then
        dm.notify('Autocmds', 'Auto `relativenumber` turned OFF')
      end
      o.relativenumber = false
    end
  end

  vim.api.nvim_create_user_command('ToggleAutoRelativeNumber', toggle_auto_relative_number, {})

  -- It's on by default.
  toggle_auto_relative_number(false)
end

-- Terminal {{{1

do
  local id = nvim_create_augroup('dm__terminal', { clear = true })

  nvim_create_autocmd('TermOpen', {
    group = id,
    pattern = 'term://*',
    command = 'setfiletype terminal',
  })

  -- Start insert mode when opening a new terminal buffer. This cannot be
  -- included in the previous autocmd because we only want this behavior when
  -- opening a "shell" terminal.
  nvim_create_autocmd('TermOpen', {
    group = id,
    pattern = 'zsh',
    command = 'startinsert',
  })

  nvim_create_autocmd('WinEnter', {
    group = id,
    pattern = 'term://*',
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(0, vim.fn.line '.', -1, false)
      lines = vim.tbl_filter(function(line)
        return line ~= ''
      end, lines)
      if vim.tbl_isempty(lines) then
        return vim.cmd 'startinsert'
      end
    end,
    desc = 'Enter insert mode only if the cursor is at the last prompt line',
  })

  nvim_create_autocmd('TermClose', {
    group = id,
    pattern = 'zsh',
    callback = function()
      api.nvim_input '<CR>'
    end,
    desc = "Avoid the annoying '[Process exited 0]' prompt",
  })
end

-- VimResized {{{1

do
  local id = nvim_create_augroup('dm__vim_resized', { clear = true })

  nvim_create_autocmd('VimResized', {
    group = id,
    callback = function()
      local last_tab = api.nvim_get_current_tabpage()
      vim.cmd 'tabdo wincmd ='
      api.nvim_set_current_tabpage(last_tab)
    end,
    desc = 'Equalize windows across tabs',
  })

  nvim_create_autocmd({ 'VimEnter', 'VimResized' }, {
    group = id,
    callback = function()
      o.previewheight = math.floor(o.lines / 3)
    end,
    desc = 'Update previewheight as per the new Vim size',
  })
end
