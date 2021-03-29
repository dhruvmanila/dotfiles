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
      {higroup="IncSearch", timeout=200}
    )]],

    -- Auto compile plugins on file update
    [[BufWritePost plugins.lua luafile %]],
    [[BufWritePost plugins.lua PackerSync]],

    -- Check if file changed when its window is focus, more eager than 'autoread'
    [[FocusGained * checktime]],
    [[FileChangedShellPost * 
      echohl WarningMsg | 
      echo "File changed on disk. Buffer reloaded." | 
      echohl None]],
  }
}

create_augroups(augroups)
