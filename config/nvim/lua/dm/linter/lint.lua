local M = {}

local api = vim.api
local if_nil = vim.F.if_nil
local log = require 'dm.log'

-- Types {{{

---@class Linter
---@field cmd string
---@field args string[]|fun(bufnr: number):string[] (default: {})
---@field enable? boolean|fun(bufnr: number):boolean? (default: nil)
---@field stdin? boolean (default: true)
---@field append_fname? boolean (default: true)
---@field stream? '"stdout"'|'"stderr"' (default: "stdout")
---@field ignore_exitcode? boolean|number[] (default: false)
---@field env? table<string, string>
---@field parser fun(output: string, bufnr: number): table
---@field namespace number

-- }}}

---@type table<string, Linter[]>
local registered_linters = {}

---@param bufnr number
---@param linter Linter
local function run_linter(bufnr, linter)
  if
    linter.enable ~= nil
    and (linter.enable == false or linter.enable(bufnr) == false)
  then
    return
  end

  -- Create a local copy of the command and arguments.
  local cmd = { linter.cmd }
  local resolved_args = linter.args
  if type(resolved_args) == 'function' then
    resolved_args = resolved_args(bufnr)
  end
  vim.list_extend(cmd, resolved_args)

  local writer
  if not linter.stdin and linter.append_fname then
    table.insert(cmd, api.nvim_buf_get_name(bufnr))
  else
    writer = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end

  if linter.env then
    if not linter.env['PATH'] then
      -- Always include PATH as we need it to execute the linter command.
      linter.env['PATH'] = os.getenv 'PATH'
    end
  end

  vim.system(
    cmd,
    {
      env = linter.env,
      stdin = writer,
    },
    ---@param result SystemCompleted
    vim.schedule_wrap(function(result)
      if
        (linter.ignore_exitcode == false and result.code > 0)
        or (
          type(linter.ignore_exitcode) == 'table'
          and vim.tbl_contains(linter.ignore_exitcode, result.code)
        )
      then
        log.fmt_error('%s exited with exit code: %d', linter.cmd, result.code)
        return
      end
      local output = result[linter.stream]
      local diagnostics = linter.parser(output, bufnr)
      vim.diagnostic.set(linter.namespace, bufnr, diagnostics)
    end)
  )
end

-- Register the linters for the given filetype.
---@param filetype string
---@param linter Linter
function M.register(filetype, linter)
  if not registered_linters[filetype] then
    registered_linters[filetype] = {}
  end

  linter.stdin = if_nil(linter.stdin, true)
  linter.append_fname = if_nil(linter.append_fname, not linter.stdin)
  linter.stream = linter.stream or 'stdout'
  linter.ignore_exitcode = if_nil(linter.ignore_exitcode, false)

  -- Every linter will have its own namespace {{{
  --
  -- If the diagnostics table is empty, then `vim.diagnostic.set` will reset
  -- the diagnostics for that buffer and namespace.
  -- See `$VIMRUNTIME/lua/vim/diagnostic:590`
  --
  -- This will create an issue in the case of a filetype having multiple
  -- linters and a global namespace is being used. If linter A sets some
  -- diagnostics in the buffer but linter B did not have any, then the act of
  -- setting an empty diagnostics from linter B will reset the ones from
  -- linter A.
  -- }}}
  linter.namespace = api.nvim_create_namespace('dm__linter_' .. linter.cmd)

  table.insert(registered_linters[filetype], linter)
end

function M.lint()
  local bufnr = api.nvim_get_current_buf()
  local linters = registered_linters[vim.bo[bufnr].filetype]
  if not linters then
    return
  end
  for _, linter in ipairs(linters) do
    run_linter(bufnr, linter)
  end
end

-- For debugging purposes.
M._registered_linters = registered_linters

return M
