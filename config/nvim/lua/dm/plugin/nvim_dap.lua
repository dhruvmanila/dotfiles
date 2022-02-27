local job = require "dm.job"
local dap = require "dap"
local dapui = require "dapui"
local dap_python = require "dap-python"

-- Available: "trace", "debug", "info", "warn", "error" or `vim.lsp.log_levels`
dap.set_log_level(vim.env.DEBUG and "debug" or "warn")

vim.fn.sign_define {
  { name = "DapStopped", text = "", texthl = "" },
  { name = "DapLogPoint", text = "", texthl = "" },
  { name = "DapBreakpoint", text = "", texthl = "Orange" },
  { name = "DapBreakpointCondition", text = "", texthl = "Orange" },
  { name = "DapBreakpointRejected", text = "", texthl = "Red" },
}

vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {
  desc = "DAP: Toggle breakpoint",
})
vim.keymap.set("n", "<leader>dB", function()
  vim.ui.input({ prompt = "Breakpoint Condition: " }, function(condition)
    if condition then
      dap.set_breakpoint(condition)
    end
  end)
end, { desc = "DAP: Set breakpoint with condition" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run last" })
vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, {
  desc = "DAP: Run to cursor",
})
vim.keymap.set("n", "<leader>dx", dap.restart, { desc = "DAP: Restart" })
vim.keymap.set("n", "<leader>ds", function()
  dap.terminate()
  dapui.close()
end, { desc = "DAP: Terminate and close UI" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
vim.keymap.set("n", "<leader>dr", function()
  dap.repl.toggle { height = math.floor(vim.o.lines * 0.3) }
end, { desc = "DAP: Toggle repl" })

-- Default exception breakpoints as per the config/adapter type.
---@see https://github.com/microsoft/debugpy/blob/main/src/debugpy/adapter/clients.py#L145-L164
dap.defaults.python.exception_breakpoints = { "uncaught", "userUnhandled" }

-- REPL completion to trigger automatically on any of the completion trigger
-- characters reported by the debug adapter or on '.' if none are reported.
dm.augroup("dm__dap_repl", {
  {
    events = "FileType",
    targets = "dap-repl",
    command = require("dap.ext.autocompl").attach,
  },
  {
    events = "BufEnter",
    targets = "\\[dap-repl\\]",
    command = "startinsert",
  },
})

-- Automatically open/close the DAP UI.
-- FIXME: terminated/exited events are not being triggered?
dap.listeners.after["event_initialized"]["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before["event_terminated"]["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before["event_exited"]["dapui_config"] = function()
  dapui.close()
end

-- Extensions {{{1

dap_python.test_runner = "pytest"
dap_python.setup(vim.loop.os_homedir() .. "/.neovim/.venv/bin/python", {
  -- We will define the configuration ourselves for additional config options.
  include_configs = false,
})

-- UI Config
dapui.setup {
  mappings = {
    expand = { "<CR>", "<2-LeftMouse>", "<Tab>" },
  },
  sidebar = {
    size = math.floor(vim.o.columns * 0.4),
    elements = {
      { id = "scopes", size = 0.8 },
      -- { id = "watches", size = 0.2 },
      -- { id = "breakpoints", size = 0.1 },
      { id = "stacks", size = 0.2 },
    },
  },
  tray = {
    size = math.floor(vim.o.lines * 0.3),
  },
  floating = {
    border = dm.border[vim.g.border_style],
  },
}

-- require("nvim-dap-virtual-text").setup {
--   enabled = true,
--   commented = true, -- prefix virtual text with `commentstring`
-- }

-- Adapters {{{1

dap.adapters.lldb = {
  name = "lldb",
  type = "executable",
  command = "lldb-vscode",
}

---@see https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
dap.adapters.go = function(callback)
  local port = 38697
  job {
    cmd = "dlv",
    args = function()
      local args = { "dap", "--listen", "127.0.0.1:" .. port }
      if vim.env.DEBUG then
        vim.list_extend(args, {
          "--log",
          "--log-dest",
          vim.fn.stdpath "cache" .. "/delve.log",
          "--log-output",
          "dap",
        })
      end
      return args
    end,
    detached = true,
    on_stdout = function(chunk)
      -- Wait for nvim-dap to initiate
      vim.defer_fn(function()
        require("dap.repl").append(chunk:gsub("\n$", ""))
      end, 200)
    end,
    on_exit = function(result)
      if result.code ~= 0 then
        dm.notify(
          "DAP (Go adapter - delve)",
          "dlv exited with code: " .. result.code,
          4
        )
      end
    end,
  }
  -- Wait for delve to start
  vim.defer_fn(function()
    callback { type = "server", host = "127.0.0.1", port = port }
  end, 100)
end

-- Configurations {{{1

-- Return the path to Python executable.
---@return string
local function get_python_path()
  -- Use activated virtual environment.
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end
  -- Fallback to global pyenv Python.
  return vim.fn.exepath "python"
end

-- Enable debugger logging if Neovim is opened in debug mode. To open Neovim
-- in debug mode, use the environment variable `DEBUG` like: `$ DEBUG=1 nvim`.
---@return boolean?
local function log_to_file()
  if vim.env.DEBUG then
    -- https://github.com/microsoft/debugpy/wiki/Enable-debugger-logs
    vim.env.DEBUGPY_LOG_DIR = vim.fn.stdpath "cache" .. "/debugpy"
    return true
  end
end

---@see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
dap.configurations.python = {
  {
    name = "Launch: file",
    type = "python",
    request = "launch",
    program = "${file}",
    console = "internalConsole",
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
  },
  {
    name = "Launch: module",
    type = "python",
    request = "launch",
    module = "${fileBasenameNoExtension}",
    cwd = "${fileDirname}",
    console = "internalConsole",
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
  },
  {
    type = "python",
    request = "attach",
    name = "Attach: remote",
    console = "internalConsole",
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
    host = function()
      local value = vim.fn.input "Host [127.0.0.1]: "
      if value ~= "" then
        return value
      end
      return "127.0.0.1"
    end,
    port = function()
      return tonumber(vim.fn.input "Port [5678]: ") or 5678
    end,
  },
}

-- Return a table of options for debugging a advent of code solution.
--
-- The year and day is parsed from the filename. The format of filename should
-- be `.../year<YYYY>/sol<DD>...` where the day should be zero padded. The
-- format of the options will be `{ "-y", "YYYY", "-d", "DD" }` with an
-- optional `-t` flag if the user wants to use the test input.
---@return string[]
local function get_advent_of_code_args()
  local bufname = vim.api.nvim_buf_get_name(0)
  local year, day = bufname:match ".*year(%d+)/sol(%d+)"
  if year == nil or day == nil then
    dm.notify(
      "Debug Advent of Code solution",
      "Unable to determine year/day for: " .. bufname,
      4
    )
    return {}
  end
  day = day:gsub("^0", "")
  local args = { "-y", year, "-d", day }
  if
    vim.fn.confirm(("Use test input for %s/%s?"):format(year, day), "&Yes\n&No")
    == 1
  then
    table.insert(args, "-t")
  end
  return args
end

---@see https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
dap.configurations.c = {
  {
    name = "Launch: file",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input(
        "Path to executable: ",
        vim.fn.getcwd() .. "/",
        "file"
      )
    end,
    cwd = "${workspaceFolder}",
  },
  {
    name = "Build and Launch: AOC solution",
    type = "lldb",
    request = "launch",
    program = function()
      -- Build the `aoc` executable with debug symbols.
      vim.cmd "!make --always-make DEBUG=1"
      return vim.loop.cwd() .. "/aoc"
    end,
    cwd = "${workspaceFolder}",
    args = get_advent_of_code_args,
  },
}

---@see https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "go",
    name = "Launch: file",
    request = "launch",
    mode = function()
      return vim.endswith(vim.api.nvim_buf_get_name(0), "_test.go") and "test"
        or "debug"
    end,
    program = "${file}",
  },
  {
    type = "go",
    name = "Launch: Advent of Code solution",
    request = "launch",
    mode = "debug",
    program = "${workspaceFolder}",
    args = get_advent_of_code_args,
  },
}

-- }}}1

-- Add configurations from `.vscode/launch.json` file
require("dap.ext.vscode").load_launchjs()
