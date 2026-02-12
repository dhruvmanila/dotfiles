local M = {}

-- Return `true` if the current buffer is empty, `false` otherwise.
---@param bufnr? integer
---@return boolean
function M.buf_is_empty(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_line_count(bufnr) == 1
    and vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)[1] == ''
end

-- Create and return a timer for the given callback to be invoked every `interval` ms.
--
-- It is the caller's responsibility to stop the timer when it is no longer needed
-- with `timer:stop()`.
--
-- The callback is invoked immediately for the first time and then every `interval` ms.
---@param interval number in milliseconds
---@param callback function
---@return uv.uv_timer_t #timer handle (uv_timer_t)
function M.set_interval_callback(interval, callback)
  local timer = assert(vim.uv.new_timer())
  timer:start(0, interval, function()
    callback()
  end)
  return timer
end

-- Returns the current buffer's LSP client for the given language server name.
-- Raises an error if no client is found.
---@param name string
---@return vim.lsp.Client
function M.get_client(name)
  return assert(
    vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), name = name })[1],
    ('No %s client found for the current buffer'):format(name)
  )
end

-- Helper function to ask the user for arguments.
---@return string[]
function M.ask_for_arguments()
  local args = vim.fn.input 'Arguments: '
  return vim.split(args, ' +', { trimempty = true })
end

local ELLIPSIS = '...'

-- Truncate the message to fit the command line.
--
-- This is to avoid the "Press Enter" prompt which blocks the UI. It uses the `v:echospace` to
-- determine the limit.
---@param message string
---@return string
function M.truncate_echo_message(message)
  local limit = vim.v.echospace
  if string.len(message) > limit then
    return string.sub(message, 1, limit - string.len(ELLIPSIS)) .. ELLIPSIS
  end
  return message
end

do
  -- Path to `mypy_primer` projects directory.
  local MYPY_PRIMER_PROJECTS_DIR = '/private/tmp/mypy_primer/projects'

  -- Check if the `root_dir` is in the `mypy_primer` projects directory and return the virtual
  -- environment corresponding to that project if it exists.
  ---@param root_dir string
  ---@return string|nil
  function M.find_mypy_primer_venv(root_dir)
    if not dm.path_exists(MYPY_PRIMER_PROJECTS_DIR) then
      return
    end
    local relative_path = vim.fs.relpath(MYPY_PRIMER_PROJECTS_DIR, root_dir)
    if not relative_path then
      return
    end
    local project_name = vim.split(relative_path, '/', { plain = true })[1]
    local venv_dir = vim.fs.joinpath(MYPY_PRIMER_PROJECTS_DIR, '_' .. project_name .. '_venv')
    if not dm.path_exists(venv_dir) then
      return
    end
    return venv_dir
  end
end

-- TODO: Maybe the first parameter should be `content` followed by `opts` table containing various
-- information like `name`, etc.

-- Open a new tab with a temporary buffer of the given `name` containing the given `content`.
-- The buffer will be deleted when the user presses `q` in normal mode.
---@param name string
---@param content string
function M.temp_buffer(name, content)
  vim.cmd.tabnew()
  local lines = vim.split(content, '\n', { plain = true, trimempty = true })
  vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_buf_set_name(0, name)
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_buf_delete(0, { force = true })
  end, { buffer = true, nowait = true })
  vim.opt_local.modifiable = false
  vim.opt_local.modified = false
end

return M
