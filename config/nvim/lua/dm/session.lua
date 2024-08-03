local M = {}

local fn = vim.fn
local api = vim.api

local dashboard = require 'dm.dashboard'

-- Notification title for the plugin
local TITLE = 'Session Manager'

-- Separator used to separate the session name and the branch name.
local BRANCH_SEPARATOR = '@@'

-- Default session directory.
local SESSION_DIR = fn.stdpath 'data' .. '/sessions'

-- Timeout (in seconds) for various `git` commands.
local TIMEOUT = 3 * 1000
-- Exit code when the process is timed out. This is set by `vim.system`.
local TIMEOUT_EXIT_CODE = 124

---@type Session?
local active_session = nil

local logger = dm.log.get_logger 'dm.session'

do
  local info = vim.uv.fs_stat(SESSION_DIR)
  if not info or info.type ~= 'directory' then
    vim.uv.fs_mkdir(SESSION_DIR, tonumber('755', 8))
  end
end

-- Given a Yes/No question, return `true` if the user answered Yes, `false`
-- otherwise.
---@param question string
---@return boolean
local function confirm(question)
  return fn.confirm(question, '&Yes\n&No') == 1
end

-- Return the `git` branch for the given project.
---@param project string
---@return string?
local function project_git_branch(project)
  local branch = vim.b.gitsigns_head
  if branch == nil or branch == '' then
    if vim.fs.root(project, '.git') == nil then
      logger.debug('Not a git repository (or any of the parent directories): %s', project)
      return
    end
    local result = vim.system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }):wait(TIMEOUT)
    if result.code == TIMEOUT_EXIT_CODE then
      logger.warn('Timeout while getting the git branch in %s', project)
    elseif result.code > 0 then
      logger.error('Failed to get git branch in %s: %s', project, result.stderr)
    else
      branch = vim.trim(result.stdout)
    end
  end
  if branch ~= '' then
    return branch
  end
end

-- Return `true` if the given `git` branch exists for the given project, `false`
-- otherwise.
---@param project string
---@param branch string
---@return boolean
local function git_branch_exists(project, branch)
  local result = vim
    .system({ 'git', 'show-ref', '--heads', '--quiet', branch }, { cwd = project })
    :wait(TIMEOUT)
  if result.code == TIMEOUT_EXIT_CODE then
    logger.warn('Timeout while checking if the git branch (%s) exists in %s', branch, project)
    return false
  end
  return result.code == 0
end

---@class Session
local Session = {}
Session.__index = Session

-- Create a new `Session` instance for the current project.
---@return Session
function Session:new()
  local project = vim.fn.getcwd()
  local branch = project_git_branch(project)
  local name = project:gsub(dm.OS_HOMEDIR, ''):sub(2)
  local path = project
  if branch ~= nil then
    name = name .. BRANCH_SEPARATOR .. branch
    path = path .. BRANCH_SEPARATOR .. branch
  end
  path = path:gsub('/', '%%')
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
    name = name:gsub(dm.OS_HOMEDIR, ''):sub(2),
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

-- Return `true` if the session is dangling, `false` otherwise. A session is
-- dangling if it's not active, either the project directory or the `git` branch
-- doesn't exist.
---@return boolean
function Session:is_dangling()
  return not self:is_active()
    and (
      fn.isdirectory(self.project) == 0
      or (self.branch ~= nil and not git_branch_exists(self.project, self.branch))
    )
end

-- Return `true` if the session file exists, `false` otherwise.
---@return boolean
function Session:exists()
  return fn.filereadable(self.path) == 1
end

function Session:__tostring()
  local name = self.project:gsub(dm.OS_HOMEDIR, ''):sub(2)
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
  vim.lsp.stop_client(vim.lsp.get_clients())
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
  elseif confirm('Remove ' .. session.name .. '?') then
    local ok, err = vim.uv.fs_unlink(session.path)
    if ok then
      if session.path == vim.v.this_session then
        active_session = nil
        vim.v.this_session = ''
      end
      dm.notify(TITLE, 'Deleted session ' .. session.name)
      return true
    else
      logger.error('Failed to delete session (%s): %s', session.name, err)
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

-- Delete the dangling sessions after prompting for confirmation.
function M.clean()
  local dangling_sessions = {}
  for _, session in ipairs(M.list()) do
    if session:is_dangling() then
      table.insert(dangling_sessions, session)
    end
  end
  if #dangling_sessions == 0 then
    dm.notify(TITLE, 'No dangling sessions to delete')
    return
  end
  local prompt = ('Delete the following %d dangling sessions?\n  %s'):format(
    #dangling_sessions,
    table.concat(vim.tbl_map(tostring, dangling_sessions), '\n  ')
  )
  if confirm(prompt) then
    local deleted = 0
    for _, session in ipairs(dangling_sessions) do
      local ok, err = vim.uv.fs_unlink(session.path)
      if ok then
        deleted = deleted + 1
      else
        logger.error('Failed to delete session (%s): %s', session.name, err)
      end
    end
    dm.notify(TITLE, ('Deleted %d dangling sessions'):format(deleted))
  else
    dm.notify(TITLE, 'Deletion aborted')
  end
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
  dashboard.open()
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
  -- Sort the sessions in a way that all of the sessions in the current project
  -- are at the top.
  local project = vim.fn.getcwd()
  ---@param s1 Session
  ---@param s2 Session
  table.sort(sessions, function(s1, s2)
    if s1.project == project and s2.project ~= project then
      return true
    elseif s1.project ~= project and s2.project == project then
      return false
    end
    return s1.name < s2.name
  end)
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
  logger.info('Loading file: %s', session.path)
  local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(session.path))
  if not ok then
    logger.error('Failed to load file: %s', err)
    dashboard.open()
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
        :wait(TIMEOUT)
      if result.code == TIMEOUT_EXIT_CODE then
        logger.warn(
          'Timeout while switching the git branch (%s) in %s',
          selection.branch,
          selection.project
        )
      elseif result.code > 0 then
        logger.error(
          'Failed to switch git branch (%s) in %s: %s',
          selection.branch,
          selection.project,
          result.stderr
        )
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
  logger.info('Writing file: %s', session_file)
  session_cleanup()
  vim.cmd.mksession { vim.fn.fnameescape(session_file), bang = true }
end

return M
