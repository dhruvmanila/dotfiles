if vim.g.loaded_session then
  return
end
vim.g.loaded_session = true

local fn = vim.fn
local command = dm.command

local session = require "session"

-- By default, every session we open will be saved automatically when Vim exits.
--
-- If there's any need to stop *tracking* a session, we can add that
-- functionality then.
dm.augroup("dm__session_persistence", {
  {
    events = "VimLeavePre",
    targets = "*",
    command = function()
      local current_session = vim.v.this_session
      if current_session ~= "" and fn.filewritable(current_session) == 1 then
        session.write(current_session)
      end
    end,
  },
})

-- We will save the function in our global namespace, so that Vim can acess it
-- from the command-line to get the completion candidates.
dm._session_list = session.list

do
  local opts = { nargs = 1, complete = "customlist,v:lua.dm._session_list" }

  command("SClose", session.close)
  command("SDelete", session.delete, opts)
  command("SLoad", session.load, opts)
  command("SRename", session.rename, opts)
  command("SSave", session.save, opts)
end

-- One caveat for storing 'curdir': {{{
--
-- If we open a session from another directory in the shell, the directory
-- in Vim will differ from that in the shell. It should not matter as our
-- cwd in Vim is determined from the file using root patterns (`vim-rooter`).
-- }}}
-- We're also not interested in some of the default values: {{{
--
--   * blank: no point in saving empty windows
--   * buffers: we don't want to restore hidden and unloaded buffers
--   * folds: we don't want local fold options to be saved, because if we make
--     some experiments and change some options/mappings during a session, we
--     don't want those to be restored
-- }}}
vim.opt.sessionoptions = { "curdir", "help", "tabpages", "winsize" }
