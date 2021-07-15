local session = {}

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

-- Delete all the buffers. This is useful when switching between sessions or
-- closing the current session.
local function delete_buffers()
  cmd "%bdelete!"
end

-- Cleanup performed before saving the session. This includes:
--   - Closing all the popup window
--   - Closing all the 'NvimTree' window
--   - Quitting the Dashboard buffer
--   - Stop all the active LSP clients
local function session_cleanup()
  for _, winnr in ipairs(api.nvim_list_wins()) do
    if fn.win_gettype(winnr) == "popup" then
      api.nvim_win_close(winnr, true)
    end
  end

  if vim.o.filetype == "dashboard" then
    local calling_buffer = fn.bufnr "#"
    if calling_buffer > 0 then
      api.nvim_set_current_buf(calling_buffer)
    end
  end

  if plugin_loaded "nvim-tree.lua" then
    local curtab = api.nvim_get_current_tabpage()
    cmd "silent tabdo NvimTreeClose"
    api.nvim_set_current_tabpage(curtab)
  end

  vim.lsp.stop_client(vim.lsp.get_active_clients())
end

-- Make/save the current session to the given path.
---@param path string
function session.write(path)
  session_cleanup()
  cmd("mksession! " .. path)
end

-- Load the given session name. If we are already in another session, first
-- save that and then open the new one.
---@param name string
function session.load(name)
  local path = vim.g.session_dir .. "/" .. name
  local current_session = vim.v.this_session
  if fn.filereadable(path) == 1 then
    if fn.filewritable(current_session) == 1 then
      session.write(current_session)
    end
    delete_buffers()
    cmd("source " .. path)
  else
    print("No such session exist: " .. path)
  end
end

-- Save the given session name. If it already exists, ask for confirmation to
-- overwrite the session.
---@param name string
function session.save(name)
  local path = vim.g.session_dir .. "/" .. name
  if
    fn.filereadable(path) == 0
    or fn.confirm("Session already exists. Overwrite?", "&Yes\n&No") == 1
  then
    session.write(path)
    print("Session saved under: " .. path)
    return
  else
    print "Did NOT save the session"
  end
end

-- Close the current session if it exists and open the Dashboard.
function session.close()
  local current_session = vim.v.this_session
  if fn.filewritable(current_session) then
    session.write(current_session)
    vim.v.this_session = ""
  end
  delete_buffers()
  cmd "Dashboard"
end

-- Delete the given session if the user confirms.
---@param name string
function session.delete(name)
  local path = vim.g.session_dir .. "/" .. name
  if fn.filereadable(path) == 0 then
    print("No such session exist: " .. path)
  elseif fn.confirm("Really delete " .. path .. "?", "&Yes\n&No") == 1 then
    if vim.loop.fs_unlink(path) then
      print("Deleted session " .. path)
    else
      api.nvim_err_writeln("Failed to delete session: " .. path)
    end
  else
    print "Deletion aborted"
  end
end

-- Return a list of all the available sessions in the session directory.
-- If `arglead` is provided, use that to return only the sessions which match
-- the string. This is mainly used for completion on the command-line.
---@param arglead? string
---@return string[]
function session.list(arglead)
  arglead = arglead and (".*" .. arglead .. ".*")
  return fn.readdir(vim.g.session_dir, function(filename)
    return arglead and (filename:match(arglead) and 1 or 0) or 1
  end)
end

return session
