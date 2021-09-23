local M = {}

local api = vim.api
local if_nil = vim.F.if_nil
local log = dm.log
local job = require "dm.job"

-- Types {{{

---@class Linter
---@field cmd string
---@field args string[]|function
---@field stdin? boolean (default: true)
---@field stream? '"stdout"'|'"stderr"' (default: "stdout")
---@field ignore_exitcode? boolean (default: false)
---@field env? table<string, string>
---@field parser fun(output: string, bufnr: number): table
---@field private _ns number

-- }}}

---@type table<string, Linter[]>
local registered_linters = {}

---@param bufnr number
---@param linter Linter
local function run_linter(bufnr, linter)
  local writer
  local args = linter.args
  if type(args) == "function" then
    args = args()
  end
  if not linter.stdin then
    -- Do NOT mutate the original `args` table.
    args = vim.deepcopy(args)
    table.insert(args, api.nvim_buf_get_name(bufnr))
  else
    writer = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end

  job {
    cmd = linter.cmd,
    args = args,
    env = linter.env,
    writer = writer,
    on_exit = function(result)
      if not linter.ignore_exitcode and result.code > 0 then
        log.fmt_error("%s exited with exit code: %d", linter.cmd, result.code)
        return
      end
      local output = result[linter.stream]
      local diagnostics = linter.parser(output, bufnr)
      vim.diagnostic.set(linter._ns, bufnr, diagnostics)
    end,
  }
end

-- Register the linters for the given filetype.
---@param filetype string
---@param linter Linter
function M.register(filetype, linter)
  if not registered_linters[filetype] then
    registered_linters[filetype] = {}
  end

  linter.stdin = if_nil(linter.stdin, true)
  linter.stream = linter.stream or "stdout"
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
  linter._ns = api.nvim_create_namespace(
    ("dm__diagnostics_%s_%s"):format(filetype, linter.cmd)
  )

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
