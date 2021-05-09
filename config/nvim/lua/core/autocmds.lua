require("core.utils").create_augroups({
  custom_autocmds = {
    -- Highlight current cursorline (cul), but only in active window
    [[WinEnter,BufEnter * if !&cul && &ft !~# '^\(dashboard\)' | setl cul | endif]],
    [[WinLeave,BufLeave * if &cul && &ft !~# '^\(dashboard\)' | setl nocul | endif]],

    -- Equalize window dimensions when resizing vim
    [[VimResized * Equalize]],

    -- Highlighted yank
    [[TextYankPost * silent! lua vim.highlight.on_yank({higroup="Substitute", timeout=200})]],

    -- Start syncing syntax highlighting 200 lines before the current line
    [[Syntax * syntax sync minlines=200]],

    -- Keep the plugins in sync (clean, update, install, compile)
    -- [[BufWritePost plugins.lua luafile %]],
    -- [[BufWritePost plugins.lua PackerSync]],

    -- Check if file changed (more eager than 'autoread')
    [[FocusGained,BufEnter * checktime]],

    -- Automatically go to insert mode on terminal buffer
    [[TermOpen * startinsert]],
    [[BufEnter term://* startinsert]],

    -- Remove trailing whitespace and lines on save
    [[BufWritePre * TrimTrailingWhitespace | TrimTrailingLines]],
  },
})
