local M = {}

local fn = vim.fn
local uv = vim.loop
local api = vim.api

local dashboard = require 'dm.dashboard'
local log = require 'dm.log'

-- Notification title for the plugin
local TITLE = 'Session Manager'

-- Separator used to separate the session name and the branch name.
local BRANCH_SEPARATOR = '@@'

-- Default session directory.
local SESSION_DIR = fn.stdpath 'data' .. '/sessions'

---@type Session?
local active_session = nil

do
  local info = uv.fs_stat(SESSION_DIR)
  if not info or info.type ~= 'directory' then
    uv.fs_mkdir(SESSION_DIR, tonumber(755, 8))
  end
end

-- Given a Yes/No question, return `true` if the user answered Yes, `false`
-- otherwise.
---@param question string
---@return boolean
local function confirm(question)
  return fn.confirm(question .. '?', '&Yes\n&No') == 1
end

-- Return the `git` branch for the current project.
---@return string?
local function current_git_branch()
  local branch = vim.b.gitsigns_head
  if branch == nil or branch == '' then
    local result = vim.system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }):wait()
    if result.code > 0 then
      dm.notify(TITLE, { 'Failed to get git branch:', '', result.stderr }, vim.log.levels.ERROR)
      return
    end
    branch = vim.trim(result.stdout)
  end
  if branch ~= '' then
    return branch
  end
end

---@class Session
---
---The `git` branch for the session. This is `nil` if the project is not a
---`git` repository.
---@field branch string?
---
---The name of the session. This is automatically generated based on the
---project directory and the `git` branch. If the project is not a `git`
---repository, then the name is just the project directory name. This excludes
---the home directory.
---@field name string
---
---The absolute path to the session file.
---@field path string
---
---The absolute path to the project directory for the session.
---@field project string

---@type Session
local Session = {}
Session.__index = Session

-- Create a new `Session` instance for the current project.
---@return Session
function Session:new()
  local project = vim.fn.getcwd()
  local branch = current_git_branch()
  local name = project:gsub(vim.g.os_homedir, ''):sub(2)
  local path = project
  if branch ~= nil then
    name = name .. BRANCH_SEPARATOR .. branch
    path = (path .. BRANCH_SEPARATOR .. branch):gsub('/', '%%')
  end
  return setmetatable({
    name = name,
    project = project,
    branch = branch,
    path = vim.fs.joinpath(SESSION_DIR, path) .. '.vim',
  }, self)
end

-- Create a new `Session` instance from the absolute path to the session file.
---@param path string
---@return Session
function Session:from_session_file(path)
  local filename = vim.fs.basename(path)
  local name = filename:gsub('%%', '/'):sub(1, -5)
  local parts = vim.split(name, BRANCH_SEPARATOR, { plain = true })
  return setmetatable({
    name = name:gsub(vim.g.os_homedir, ''):sub(2),
    project = parts[1],
    branch = parts[2],
    path = path,
  }, self)
end

-- Return `true` if the session is active, `false` otherwise. This is checked
-- using the `vim.v.this_session` variable.
---@return boolean
function Session:is_active()
  return self.path == vim.v.this_session
end

-- Return `true` if the session file exists, `false` otherwise.
---@return boolean
function Session:exists()
  return fn.filereadable(self.path) == 1
end

function Session:__tostring()
  local name = self.project:gsub(vim.g.os_homedir, ''):sub(2)
  if self.branch then
    name = name .. ' (' .. self.branch .. ')'
  end
  if self:is_active() then
    name = name .. ' (*)'
  end
  return name
end

-- Delete all the buffers. This is useful when stopping the active session.
local function delete_buffers()
  vim.cmd 'silent %bdelete!'
end

-- Stop all the LSP clients.
local function stop_lsp_clients()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
end

-- Cleanup performed before saving the session. This includes:
--   - Close all the popup windows
--   - Quit the Dashboard buffer
local function session_cleanup()
  for _, winnr in ipairs(api.nvim_list_wins()) do
    if fn.win_gettype(winnr) == 'popup' then
      api.nvim_win_close(winnr, true)
    end
  end

  if vim.o.filetype == 'dashboard' then
    local calling_buffer = fn.bufnr '#'
    if calling_buffer > 0 then
      api.nvim_set_current_buf(calling_buffer)
    end
  end
end

-- Delete the given session after prompting for confirmation.
---@param session Session
---@return boolean # `true` if the session was deleted, `false` otherwise.
local function session_delete(session)
  if not session:exists() then
    dm.notify(TITLE, 'No such session: ' .. session.name, vim.log.levels.WARN)
  elseif confirm('Remove ' .. session.name) then
    local ok, err = uv.fs_unlink(session.path)
    if ok then
      if session.path == vim.v.this_session then
        active_session = nil
        vim.v.this_session = ''
      end
      dm.notify(TITLE, 'Deleted session ' .. session.name)
      return true
    else
      dm.notify(
        TITLE,
        { 'Failed to delete session ' .. session.name .. ':', '', err },
        vim.log.levels.ERROR
      )
    end
  else
    dm.notify(TITLE, 'Deletion aborted')
  end
  return false
end

-- Return the information about the active session, `nil` if there is none.
---@return { name: string, path: string, project: string, branch?: string }?
function M.active_session()
  if active_session == nil then
    return nil
  end
  return {
    name = active_session.name,
    path = active_session.path,
    project = active_session.project,
    branch = active_session.branch,
  }
end

-- Close the current session if it exists and open the Dashboard.
function M.close()
  if active_session == nil then
    dm.notify(TITLE, 'No active session to close')
    return
  end
  M.stop()
  stop_lsp_clients()
  delete_buffers()
  dashboard.open(false)
end

-- Using `vim.ui.select`, prompt the user to select a session to delete.
function M.delete()
  vim.ui.select(M.list(), {
    prompt = 'Delete session',
    kind = 'session',
  }, function(selection)
    if selection then
      session_delete(selection)
    end
  end)
end

-- Return a list of all the available sessions in the session directory.
---@return Session[]
function M.list()
  local sessions = {}
  for filename, itemtype in vim.fs.dir(SESSION_DIR) do
    if itemtype == 'file' and vim.endswith(filename, '.vim') then
      local session_file = vim.fs.joinpath(SESSION_DIR, filename)
      table.insert(sessions, Session:from_session_file(session_file))
    end
  end
  return sessions
end

-- Load the session at the given `session_file` path. If no path is given,
-- load the session for the current working directory and git branch, if any.
---@param session? Session
function M.load(session)
  session = session or Session:new()
  if not session:exists() then
    dm.notify(TITLE, 'No such session: ' .. session.name, vim.log.levels.WARN)
    return
  end
  if active_session ~= nil then
    if session.path == active_session.path then
      dm.notify(TITLE, 'Session is already active')
      return
    end
    -- Save the current session first.
    M.write(active_session.path)
  end
  -- Stop the LSP clients only if the project has changed.
  if session.project ~= (active_session and active_session.project or vim.fn.getcwd()) then
    stop_lsp_clients()
  end
  log.fmt_info('Loading session file: %s', session.path)
  local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(session.path))
  if not ok then
    log.fmt_error('Failed to load session file: %s', err)
    dashboard.open(false)
  else
    active_session = session
  end
end

-- Save the active session or the session for the current working directory and
-- git branch, if any.
function M.save()
  local session = active_session or Session:new()
  M.write(session.path)
  active_session = session
  dm.notify(TITLE, 'Session saved for ' .. session.name)
end

-- Using `vim.ui.select`, prompt the user to select a session to load.
function M.select()
  vim.ui.select(M.list(), {
    prompt = 'Select session',
    kind = 'session',
  }, function(selection)
    if selection then
      local result = vim
        .system({ 'git', 'checkout', selection.branch }, {
          cwd = selection.project,
        })
        :wait(1 * 1000) -- 1 second
      if result.code > 0 then
        dm.notify(TITLE, {
          ('Failed to switch branch (%s):'):format(selection.branch),
          '',
          result.stderr,
        })
      else
        M.load(selection)
      end
    end
  end)
end

-- Stop the active session, saving it first.
function M.stop()
  if active_session == nil then
    dm.notify(TITLE, 'No active session to stop')
    return
  end
  M.write(active_session.path)
  active_session = nil
  vim.v.this_session = ''
  dm.notify(TITLE, 'Active session stopped')
end

-- Make/save the current session to the given path.
---@param session_file string
function M.write(session_file)
  log.fmt_info('Writing session file: %s', session_file)
  session_cleanup()
  vim.cmd.mksession { vim.fn.fnameescape(session_file), bang = true }
end

return M
