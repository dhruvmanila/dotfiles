local create_augroups = require('core.utils').create_augroups

local augroups = {
  -- Highlight current line, but only in active window
  cursor_line_only_in_active_window = {
    [[WinEnter,BufEnter * setlocal cursorline]],
    [[WinLeave,BufLeave * setlocal nocursorline]]
  },

  -- Equalize window dimensions when resizing vim
  equalize_window = {
    [[VimResized * wincmd =]]
  },

  -- Highlighted yank
  highlight_yank = {
    [[TextYankPost * silent! lua vim.highlight.on_yank(
      {higroup="IncSearch", timeout=200}
    )]]
  },

  -- Auto compile plugins on file update
  auto_compile_plugins = {
    [[BufWritePost plugins.lua PackerCompile]]
  }
}

create_augroups(augroups)
