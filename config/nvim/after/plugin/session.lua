-- Personal session management for neovim based on vim-startify

local command = dm.command
local session = require "dm.session"

-- Default session directory.
vim.g.session_dir = vim.fn.stdpath "data" .. "/session"

do
  -- Create the directory if it does not exists.
  local info = vim.loop.fs_stat(vim.g.session_dir)
  if not info or info.type ~= "directory" then
    vim.loop.fs_mkdir(vim.g.session_dir, 755)
  end
end

-- For completion on the command-line.
dm._session_list = session.list

do
  local opts = { nargs = 1, complete = "customlist,v:lua.dm._session_list" }

  command("SLoad", session.load, opts)
  command("SSave", session.save, opts)
  command("SDelete", session.delete, opts)
  command("SClose", session.close)
end

dm.augroup("dm__session_persistence", {
  {
    events = "VimLeavePre",
    targets = "*",
    command = function()
      local current_session = vim.v.this_session
      if
        current_session ~= ""
        and vim.fn.filewritable(current_session) == 1
      then
        session.write(current_session)
      end
    end,
  },
})
