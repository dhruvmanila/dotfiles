local M = {}

local logger = dm.log.get_logger 'dm.linter'

-- Enabled linters by filetype where the key is the filetype and the value is a
-- list of linter names.
--
-- This is used to enable linters for specific filetypes. The table can be updated
-- by the user to enable/disable linters either globally or for specific projects
-- using the `.nvim.lua` (see |exrc|) config file. For example:
--
-- ```lua
-- local linter = require('dm.linter')
--
-- -- Enable the `pylint` linter for Python files instead of the default.
-- linter.enabled_linters_by_filetype.python = {
--   'pylint',
-- }
-- ```
---@type table<string, string[]>
M.enabled_linters_by_filetype = {
  dockerfile = {
    'hadolint',
  },
  go = {
    'golangci-lint',
  },
  sql = {
    'sqlfluff',
  },
  yaml = {
    'actionlint',
  },
}

---@type table<string, LinterConfig?>
M.linters = setmetatable({}, {
  __index = function(_, name)
    local ok, linter = pcall(require, 'dm.linters.' .. name)
    if not ok then
      return nil
    end
    return linter
  end,
})

-- Namespaces for the linter diagnostics indexed by the linter command.
--
-- The namespace is created on demand when the linter is run for the first time and cached for
-- subsequent runs. Each linter has its own namespace so that the diagnostics can be cleared
-- individually.
---@type table<string, number>
local namespaces = setmetatable({}, {
  __index = function(tbl, key)
    local namespace = vim.api.nvim_create_namespace('dm__linter_' .. key)
    rawset(tbl, key, namespace)
    return namespace
  end,
})

---@param bufnr number
---@param linter LinterConfig
local function run_linter(bufnr, linter)
  if linter.enable and linter.enable(bufnr) == false then
    return
  end

  -- Create a local copy of the command and arguments.
  local cmd = { linter.cmd }
  local args = linter.args
  if args ~= nil then
    if type(args) == 'function' then
      vim.list_extend(cmd, args(bufnr))
    else
      vim.list_extend(cmd, args)
    end
  end

  local writer
  if not linter.stdin then
    table.insert(cmd, vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.'))
  else
    writer = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end

  if linter.env then
    if not linter.env['PATH'] then
      -- Always include PATH as we need it to execute the linter command.
      linter.env['PATH'] = os.getenv 'PATH'
    end
  end

  logger.info('Running linter command: %s', cmd)

  vim.system(
    cmd,
    {
      env = linter.env,
      stdin = writer,
    },
    ---@param result vim.SystemCompleted
    vim.schedule_wrap(function(result)
      if not linter.ignore_exitcode then
        if result.code > 0 then
          logger.error('Linter command "%s" exited with code: %d', linter.cmd, result.code)
          return
        end
      end
      local output = result[linter.stream or 'stdout']
      local diagnostics = linter.parser(output, bufnr)
      vim.diagnostic.set(namespaces[linter.cmd], bufnr, diagnostics)
    end)
  )
end

-- Run the linters registered for the current buffer.
function M.lint()
  local bufnr = vim.api.nvim_get_current_buf()
  local linter_names = M.enabled_linters_by_filetype[vim.bo[bufnr].filetype]
  if not linter_names then
    return
  end
  for _, linter_name in ipairs(linter_names) do
    local linter = M.linters[linter_name]
    if not linter then
      vim.notify_once(('Linter "%s" not found'):format(linter_name), vim.log.levels.WARN)
    elseif not dm.is_executable(linter.cmd) then
      vim.notify_once(('Linter "%s" not installed'):format(linter_name), vim.log.levels.WARN)
    else
      run_linter(bufnr, linter)
    end
  end
end

return M
