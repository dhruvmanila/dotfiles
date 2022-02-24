if vim.g.loaded_session then
  return
end
vim.g.loaded_session = true

local fn = vim.fn
local api = vim.api

local session = require "dm.session"

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

local function session_function_factory(function_name)
  return function(opts)
    session[function_name](opts.args)
  end
end

do
  local opts = {
    nargs = 1,
    complete = session.list,
  }

  api.nvim_add_user_command("SClose", session.close, {})
  api.nvim_add_user_command("SDelete", session_function_factory "delete", opts)
  api.nvim_add_user_command("SLoad", session_function_factory "load", opts)
  api.nvim_add_user_command("SRename", session_function_factory "rename", opts)
  api.nvim_add_user_command("SSave", session_function_factory "save", opts)
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
-- }}}
vim.opt.sessionoptions = { "curdir", "folds", "help", "tabpages", "winsize" }
