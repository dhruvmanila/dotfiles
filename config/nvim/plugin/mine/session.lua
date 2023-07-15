if vim.g.loaded_session then
  return
end
vim.g.loaded_session = true

local fn = vim.fn
local api = vim.api

local session = require 'dm.session'

-- By default, every session we open will be saved automatically when Vim exits.
--
-- If there's any need to stop *tracking* a session, we can add that
-- functionality then.
api.nvim_create_autocmd('VimLeavePre', {
  group = api.nvim_create_augroup('dm__session_persistence', { clear = true }),
  callback = function()
    local current_session = vim.v.this_session
    if current_session ~= '' and fn.filewritable(current_session) == 1 then
      session.write(current_session)
    end
  end,
  desc = 'Save the session when exiting Neovim',
})

-- Keybindings
vim.keymap.set('n', '<leader>sc', session.close, { desc = 'session: close' })
vim.keymap.set('n', '<leader>sd', session.delete, { desc = 'session: delete' })
vim.keymap.set('n', '<leader>ss', session.save, { desc = 'session: save' })
vim.keymap.set('n', '<leader>sl', session.select, { desc = 'session: load' })
vim.keymap.set('n', '<leader>st', session.stop, { desc = 'session: stop' })

-- Commands
api.nvim_create_user_command('SessionActive', function()
  vim.print(session.active_session())
end, { desc = 'session: print the active session' })

-- One caveat for storing 'curdir': {{{
--
-- If we open a session from another directory in the shell, the directory
-- in Vim will differ from that in the shell. It should not matter as our
-- cwd in Vim is determined from the file using root patterns (`vim-rooter`).
-- }}}
-- We're also not interested in the following: {{{
--
--   * blank: no point in saving empty windows
--   * folds: they are created dynamically and might be missing on startup
-- }}}
vim.opt.sessionoptions = {
  'curdir',
  'help',
  'tabpages',
  'winsize',
}
