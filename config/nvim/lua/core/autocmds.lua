local create_augroups = require('core.utils').create_augroups

local augroups = {
  custom_autocmds = {
    -- Highlight current line, but only in active window
    [[WinEnter,BufEnter * setlocal cursorline]],
    [[WinLeave,BufLeave * setlocal nocursorline]],

    -- Equalize window dimensions when resizing vim
    [[VimResized * wincmd =]],

    -- Highlighted yank
    [[TextYankPost * silent! lua vim.highlight.on_yank(
      {higroup="Substitute", timeout=200}
    )]],

    -- Keep the plugins in sync (clean, update, install, compile)
    [[BufWritePost plugins.lua luafile %]],
    [[BufWritePost plugins.lua PackerSync]],

    -- Check if file changed (more eager than 'autoread')
    -- https://unix.stackexchange.com/a/383044
    [[FocusGained,BufEnter *
      if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == ''
        | checktime
        | endif]],
    [[FileChangedShellPost *
      echohl WarningMsg
      | echo "File changed on disk. Buffer reloaded."
      | echohl None]],

    -- Automatically go to insert mode on terminal buffer
    [[TermOpen * startinsert]],

    -- Remove trailing whitespace on save
    [[BufWritePre * %s/\s\+$//e]],
  }
}

create_augroups(augroups)
