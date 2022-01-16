local job = require "dm.job"
local dap = require "dap"
local dapui = require "dapui"
local dap_python = require "dap-python"

-- Add configurations from `.vscode/launch.json` file
require("dap.ext.vscode").load_launchjs()

vim.fn.sign_define {
  { name = "DapBreakpoint", text = "", texthl = "Orange" },
  { name = "DapStopped", text = "", texthl = "" },
}

dap_python.test_runner = "pytest"
dap_python.setup(vim.loop.os_homedir() .. "/.neovim/.venv/bin/python", {
  -- Include the builtin configs which includes launching the current file with
  -- and without arguments, attaching to a remote session.
  include_configs = true,

  -- Show the output in the client's default message UI (nvim-dap REPL).
  -- Other options include `internalTerminal`, `externalTerminal`.
  console = "internalConsole",
})

vim.keymap.set("n", "<leader>dl", dap.run_last)
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<F5>", dap.continue)
-- TODO: set these mappings only during the debugging session (similar to `K`)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)
vim.keymap.set("n", "<leader>dr", dap.repl.toggle)
-- vim.keymap.set("n", "", dap.restart)
-- vim.keymap.set("n", "", dap.step_back)
-- vim.keymap.set("n", "", dap.run_to_cursor)
-- vim.keymap.set("n", "", dap.terminate --[[ dap.disconnect --]])

-- REPL completion to trigger automatically on any of the completion trigger
-- characters reported by the debug adapter or on '.' if none are reported.
dm.autocmd {
  events = "FileType",
  targets = "dap-repl",
  command = require("dap.ext.autocompl").attach,
}

-- During a debug session, remap `K` to hover a symbol using nvim-dap. Once the
-- session ends, the key will be restored.
do
  local keymap_restore = {}

  dap.listeners.after["event_initialized"]["dm"] = function()
    for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
      local keymaps = vim.api.nvim_buf_get_keymap(bufnr, "n")
      for _, keymap in pairs(keymaps) do
        if keymap.lhs == "K" then
          table.insert(keymap_restore, keymap)
          vim.keymap.del("n", "K", { buffer = bufnr })
        end
      end
    end

    vim.keymap.set("n", "K", function()
      require("dap.ui.widgets").hover(
        nil,
        { border = dm.border[vim.g.border_style] }
      )
    end)
  end

  dap.listeners.after["event_terminated"]["dm"] = function()
    for _, keymap in pairs(keymap_restore) do
      vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs or "", {
        callback = keymap.callback,
        noremap = keymap.noremap == 1,
        silent = keymap.silent == 1,
        buffer = keymap.buffer,
      })
    end
    keymap_restore = {}
  end
end

-- Automatically open/close the DAP UI.
dap.listeners.after["event_initialized"]["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before["event_terminated"]["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before["event_exited"]["dapui_config"] = function()
  dapui.close()
end

-- UI Config
dapui.setup {
  mappings = {
    expand = { "<CR>", "<2-LeftMouse>", "<Tab>" },
  },
  sidebar = {
    size = math.floor(vim.o.columns * 0.4),
    elements = {
      { id = "scopes", size = 0.6 },
      { id = "breakpoints", size = 0.2 },
      { id = "stacks", size = 0.2 },
    },
  },
  tray = {
    size = math.floor(vim.o.lines * 0.3),
  },
  floating = {
    border = "rounded",
  },
}

---@see https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go-using-delve-directly
dap.adapters.go = function(callback)
  local port = 38697
  job {
    cmd = "dlv",
    args = { "dap", "--listen", "127.0.0.1:" .. port },
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
          { "dlv exited with code: " .. result.code, result.stderr },
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

---@see https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "go",
    name = "Debug file",
    request = "launch",
    mode = "debug",
    program = "${file}",
  },
  {
    type = "go",
    name = "Debug test file", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}",
  },
  {
    type = "go",
    name = "Debug Advent of Code solution",
    request = "launch",
    mode = "debug",
    program = "${workspaceFolder}",
    args = function()
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
      local args = { "-y", year, "-d", day }
      if
        vim.fn.confirm(
          ("Use test input for %d/%d ?"):format(year, day),
          "&Yes\n&No"
        ) == 1
      then
        table.insert(args, "-t")
      end
      return args
    end,
  },
}
