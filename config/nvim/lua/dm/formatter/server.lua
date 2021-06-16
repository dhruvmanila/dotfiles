local M = {}

local uv = vim.loop
local curl = require "plenary.curl"

-- Used port numbers to avoid clashes.
local used_port = {}

-- All the daemon server process handles.
local process_handles = {}

-- Return a random port number from the Dynamic and/or Private range as per
-- https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
---@return number
local function get_random_port()
  local port
  while true do
    port = math.random(49152, 65535)
    if not vim.tbl_contains(used_port, port) then
      table.insert(used_port, port)
      return port
    end
  end
end

-- Kill all the started daemon servers and close the handlers for it.
local function kill_servers()
  for _, handle in ipairs(process_handles) do
    if handle then
      handle:kill(9)
      if not handle:is_closing() then
        handle:close()
      end
    end
  end
end

-- Start the daemon server for the given formatter.
---@param formatter Formatter
local function start_server(formatter)
  local args = type(formatter.args) == "function"
      and formatter.args(
        formatter._state.host,
        formatter._state.port
      )
    or formatter.args

  local opts = {
    args = args,
    stdio = { nil, nil, nil },
    cwd = uv.cwd(),
    detached = true,
  }

  local handle, pid_or_err
  handle, pid_or_err = uv.spawn(formatter.cmd, opts)
  if not handle then
    error(
      string.format(
        "Failed to start the daemon server for '%s': %s",
        formatter.cmd,
        pid_or_err
      )
    )
  end

  table.insert(process_handles, handle)
  formatter._state.running = true
end

-- Sends the formatting request to the running server.
---@param self Format
---@param formatter Formatter
function M.format(self, formatter)
  local input = table.concat(self.output, "\n")
  local url = string.format(
    "%s:%s",
    formatter._state.host,
    formatter._state.port
  )
  formatter.headers["Content-Type"] = "text/plain; charset=utf-8"
  curl.post(url, {
    body = input,
    headers = formatter.headers,
    callback = vim.schedule_wrap(function(response)
      if response.exit > 0 then
        error(vim.inspect(response))
      end
      local result = formatter.response_handler(response)
      local ok, body_or_err = unpack(result)
      if not ok then
        error(body_or_err)
      end
      -- Some servers do not return anything if the input is already well
      -- formatted. Eg., black
      if body_or_err and body_or_err ~= "" then
        self.output = body_or_err
      end
      self.ran_formatter = true
      return self:step()
    end),
  })
end

do
  local cleanup_set = false

  -- Register an autocmd to start the daemon server for the filetype of the
  -- respective formatter.
  ---@param filetype string
  ---@param formatter Formatter
  function M.register(filetype, formatter)
    formatter._state = formatter._state or {}
    formatter._state.host = "localhost"
    formatter._state.port = get_random_port()
    formatter._state.running = false

    dm.autocmd {
      events = { "FileType" },
      targets = { filetype },
      modifiers = { "++once" },
      command = function()
        start_server(formatter)
      end,
    }

    if not cleanup_set then
      dm.augroup("formatter_cleanup", {
        {
          events = { "VimLeavePre" },
          targets = { "*" },
          command = kill_servers,
        },
      })
      cleanup_set = true
    end
  end
end

return M
