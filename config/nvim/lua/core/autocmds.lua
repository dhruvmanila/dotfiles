require('core.utils').create_augroups {
  custom_autocmds = {
    -- Highlight current cursorline (cul), but only in active window
    [[WinEnter,BufEnter * if !&cul && &ft !~# '^\(dashboard\)' | setl cul | endif]],
    [[WinLeave,BufLeave * if &cul && &ft !~# '^\(dashboard\)' | setl nocul | endif]],

    -- Equalize window dimensions when resizing vim
    [[VimResized * wincmd =]],

    -- Highlighted yank
    [[TextYankPost * silent! lua vim.highlight.on_yank({higroup="Substitute", timeout=200})]],

    -- Keep the plugins in sync (clean, update, install, compile)
    [[BufWritePost plugins.lua luafile %]],
    [[BufWritePost plugins.lua PackerSync]],

    -- Check if file changed (more eager than 'autoread')
    -- https://unix.stackexchange.com/a/383044
    [[FocusGained,BufEnter * if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif]],
    [[FileChangedShellPost *
      echohl WarningMsg
      | echo "File changed on disk. Buffer reloaded."
      | echohl None]],

    -- Automatically go to insert mode on terminal buffer
    [[TermOpen * startinsert]],

    -- Remove trailing whitespace and lines on save
    [[BufWritePre * call utils#trim_trailing_whitespace() | call utils#trim_trailing_lines()]],
  }
}
