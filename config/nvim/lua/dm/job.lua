local uv = vim.loop
local log = require "dm.log"

---@class JobOpts
---@field cmd string
---@field args? string[] | fun():string[]
---@field cwd? string
---@field env? table<string, string>
---@field writer? string | string[]
---@field on_exit? fun(result: JobResult)

---@class JobResult
---@field code number
---@field signal number
---@field stdout string
---@field stderr string

-- Helper function to close the handles safely
-- Adopted from `plenary.job.close_safely`
local function close_safely(...)
  -- `ipairs` cannot be used because it stops as soon as `nil` is reached and
  -- most likely the `stdin` handle will be `nil`.
  for i = 1, select("#", ...) do
    local handle = select(i, ...)
    if handle and not handle:is_closing() then
      handle:close()
    end
  end
end

-- Reader for stdout and stderr.
---@param prefix '"stdout"'|'"stderr"'
---@return table
local function reader(prefix)
  prefix = prefix:upper()
  return setmetatable({ data = "" }, {
    __call = function(self, err, chunk)
      if err then
        log.fmt_error("Error while reading %s: %s", prefix, err)
      elseif chunk then
        self.data = self.data .. chunk
        log.fmt_debug("Read %s: %s", prefix, chunk)
      else
        log.fmt_debug("Buffer size for %s: %s", prefix, #self.data)
      end
    end,
  })
end

---@param opts JobOpts
return function(opts)
  vim.validate { cmd = { opts.cmd, "s" } }

  local env
  local cmd = opts.cmd
  local args = opts.args or {}
  if type(args) == "function" then
    args = args()
  end

  -- From `man environ(7)`
  --
  --     > By convention these strings have the form ``name=value''.
  if opts.env then
    for k, v in pairs(opts.env) do
      table.insert(env, ("%s=%s"):format(k, v))
    end
  end

  local stdout_handler = reader "stdout"
  local stderr_handler = reader "stderr"

  local stdin = opts.writer and uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  local handle, pid_or_err

  -- `on_exit` callback for `uv.spawn`.
  ---@param code number
  ---@param signal number
  local function on_exit(code, signal)
    log.fmt_debug("Process exited (code: %d, signal: %d)", code, signal)
    stdout:read_stop()
    stderr:read_stop()
    close_safely(handle, stdin, stdout, stderr)

    if opts.on_exit then
      vim.schedule(function()
        opts.on_exit {
          code = code,
          signal = signal,
          stdout = stdout_handler.data,
          stderr = stderr_handler.data,
        }
      end)
    end
  end

  log.fmt_debug("Spawning process: %s %s", cmd, args)
  handle, pid_or_err = uv.spawn(cmd, {
    args = args,
    stdio = { stdin, stdout, stderr },
    cwd = opts.cwd or uv.cwd(),
    env = env,
  }, on_exit)

  if not handle then
    close_safely(stdin, stdout, stderr)
    log.fmt_error("Failed to spawn process: %s", pid_or_err)
    return
  end

  log.fmt_debug("Process spawned with PID: %d", pid_or_err)
  stdout:read_start(stdout_handler)
  stderr:read_start(stderr_handler)

  if stdin then
    local writer = opts.writer
    if type(writer) == "table" then
      writer = table.concat(writer, "\n") .. "\n"
    end
    log.fmt_debug("Writing to STDIN: %s", writer)
    stdin:write(writer)
    stdin:shutdown()
  end
end
