local fn = vim.fn
local uv = vim.loop
local api = vim.api

-- We are exporting the functions to be used by:
--
--   * Dashboard: to show the last saved session and loading it up if the user
--     chooses so
--   * Telescope: an extension to list out all the available sessions and
--     perform actions
--
-- And, also by this plugin to setup the required commands and autocmds.

local session = {}

-- Variables {{{1

-- Notification title for the plugin
local TITLE = 'Session'

-- Default session directory.
local SESSION_DIR = fn.stdpath 'data' .. '/sessions'

do
  -- Create the directory if it does not exist.
  local info = uv.fs_stat(SESSION_DIR)
  if not info or info.type ~= 'directory' then
    uv.fs_mkdir(SESSION_DIR, tonumber(755, 8))
  end
end

-- Functions {{{1

-- Delete all the buffers. This is useful when switching between sessions or
-- closing the current session.
local function delete_buffers()
  vim.cmd '%bdelete!'
end

-- Cleanup performed before saving the session. This includes:
--   - Closing all the popup windows
--   - Quitting the Dashboard buffer
--   - Stop all the active LSP clients
local function session_cleanup()
  for _, winnr in ipairs(api.nvim_list_wins()) do
    if fn.win_gettype(winnr) == 'popup' then
      api.nvim_win_close(winnr, true)
    end
  end

  -- We don't want to save the dashboard buffer as it is a scratch buffer.
  -- See: `:h scratch-buffer`
  if vim.o.filetype == 'dashboard' then
    local calling_buffer = fn.bufnr '#'
    if calling_buffer > 0 then
      api.nvim_set_current_buf(calling_buffer)
    end
  end

  -- It is ok if there are no active clients.
  --
  -- `get_active_clients` will return an empty table if there are none and
  -- `stop_client` can handle it.
  vim.lsp.stop_client(vim.lsp.get_active_clients())
end

-- session.close {{{2

-- Close the current session if it exists and open the Dashboard.
function session.close()
  local current_session = vim.v.this_session
  if not current_session then
    dm.notify(TITLE, 'No active session to close')
    return
  end
  if fn.filewritable(current_session) then
    session.write(current_session)
    vim.v.this_session = ''
  end
  delete_buffers()
  vim.cmd 'Dashboard'
end

-- session.current {{{2

-- Return the name of the active session name, if any, otherwise an empty string.
---@return string
function session.current()
  local current_session = vim.v.this_session
  if current_session and current_session ~= '' then
    return vim.fs.basename(current_session)
  end
  return ''
end

-- session.delete {{{2

-- Delete the given session after prompting for confirmation.
--
-- The return value is a boolean indicating whether the session was deleted or
-- not. This could be useful information to act on for a third party integration.
---@param name string
---@return boolean
function session.delete(name)
  local session_file = SESSION_DIR .. '/' .. name
  if fn.filereadable(session_file) == 0 then
    dm.notify(TITLE, 'No such session exist: ' .. name, 3)
  elseif fn.confirm('Really delete ' .. name .. '?', '&Yes\n&No') == 1 then
    local ok, err = uv.fs_unlink(session_file)
    if ok then
      if session_file == vim.v.this_session then
        vim.v.this_session = ''
      end
      dm.notify(TITLE, 'Deleted session ' .. name)
      return true
    else
      dm.notify(TITLE, { 'Failed to delete session: ' .. name, err }, 4)
    end
  else
    dm.notify(TITLE, 'Deletion aborted')
  end
  return false
end

-- session.last {{{2

-- Return the name of the last *saved* session, nil if there is none.
---@return string|nil
function session.last()
  -- We need to store the list in a variable because `table.sort` does an
  -- in-place sorting.
  local sessions = session.list()
  if vim.tbl_isempty(sessions) then
    return nil
  end

  table.sort(sessions, function(a, b)
    a = SESSION_DIR .. '/' .. a
    b = SESSION_DIR .. '/' .. b
    -- From `man stat(2)`
    --                           ┌ time (sec) of last data modification
    --                           │
    --                   ┌───────┤
    return uv.fs_stat(a).mtime.sec > uv.fs_stat(b).mtime.sec
  end)
  return sessions[1]
end

-- session.list {{{2

-- Return a list of all the available sessions in the session directory.
--
-- If `arglead` is provided, use that to return only the sessions which contains
-- the string. This is mainly used for completion on the command-line.
---@param arglead? string
---@return string[]
function session.list(arglead)
  arglead = '^[%a%-_]*' .. (arglead or '') .. '[%a%-_]*$'
  return fn.readdir(SESSION_DIR, function(filename)
    return arglead and (filename:match(arglead) and 1 or 0) or 1
  end)
end

-- session.load {{{2

-- Load the given session name. If we are already in another session, save
-- that first and then open the requested one.
---@param name string
function session.load(name)
  local session_file = SESSION_DIR .. '/' .. name
  local current_session = vim.v.this_session
  if fn.filereadable(session_file) == 0 then
    dm.notify(TITLE, 'No such session exist: ' .. name, 4)
  elseif session_file == current_session then
    dm.notify(TITLE, name .. ' is already the current session')
  else
    if fn.filewritable(current_session) == 1 then
      session.write(current_session)
    end
    delete_buffers()
    vim.cmd('source ' .. session_file)
  end
end

-- session.rename {{{2

---@param new_name string
function session.rename(new_name)
  local session_file = SESSION_DIR .. '/' .. new_name
  local current_session = vim.v.this_session
  if not current_session then
    dm.notify(TITLE, 'No active session to rename')
    return
  elseif current_session == session_file then
    return
  end
  local ok, err = uv.fs_rename(current_session, session_file)
  if ok then
    dm.notify(
      TITLE,
      'Renamed ' .. vim.fs.basename(current_session) .. ' -> ' .. new_name
    )
    vim.v.this_session = session_file
  else
    dm.notify(TITLE, { 'Failed to rename to ' .. new_name, err }, 4)
  end
end

-- session.save {{{2

-- Save the given session name. If it already exists, ask for confirmation to
-- overwrite the session.
---@param name string
function session.save(name)
  local session_file = SESSION_DIR .. '/' .. name
  if
    fn.filereadable(session_file) == 0
    or fn.confirm('Session already exists. Overwrite?', '&Yes\n&No') == 1
  then
    session.write(session_file)
    dm.notify(TITLE, 'Session saved under: ' .. name)
    return
  else
    dm.notify(TITLE, 'Did NOT save the session')
  end
end

-- session.write {{{2

-- Make/save the current session to the given path.
---@param path string
function session.write(path)
  session_cleanup()
  --                ┌ overwrite any existing file
  --                │
  vim.cmd('mksession! ' .. path)
end

-- }}}1

return session
