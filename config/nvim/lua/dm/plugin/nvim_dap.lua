local api = vim.api
local sign_define = vim.fn.sign_define
local nvim_set_keymap = vim.api.nvim_set_keymap

local dap = require "dap"
local dap_python = require "dap-python"

-- Add configurations from `.vscode/launch.json` file
require("dap.ext.vscode").load_launchjs()

sign_define("DapBreakpoint", { text = "", texthl = "Orange" })
sign_define("DapStopped", { text = "", texthl = "TabLineSel" })

-- Debugger for Neovim
-- :h osv-dap
dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
    host = function()
      local value = vim.fn.input "Host [127.0.0.1]: "
      if value ~= "" then
        return value
      end
      return "127.0.0.1"
    end,
    port = function()
      local val = tonumber(vim.fn.input "Port: ")
      assert(val, "Please provide a port number")
      return val
    end,
  },
}

dap.adapters.nlua = function(callback, config)
  callback { type = "server", host = config.host, port = config.port }
end

dap_python.test_runner = "pytest"
dap_python.setup(vim.loop.os_homedir() .. "/.neovim/py3/bin/python3", {
  include_configs = true,
})

do
  local opts = { noremap = true, silent = true }

  local mappings = {
    ["<leader>dl"] = "require('dap').run_last()",
    ["<leader>dc"] = "require('dap').continue()",
    ["<leader>ds"] = "require('dap').step_over()",
    ["<leader>di"] = "require('dap').step_into()",
    ["<leader>do"] = "require('dap').step_out()",
    ["<leader>dr"] = "require('dap').repl.toggle()",
    ["<leader>db"] = "require('dap').toggle_breakpoint()",
  }

  for key, command in pairs(mappings) do
    command = "<Cmd>lua " .. command .. "<CR>"
    nvim_set_keymap("n", key, command, opts)
  end
end

do
  local keymap_restore = {}

  dap.listeners.after["event_initialized"]["dm"] = function()
    for _, bufnr in pairs(api.nvim_list_bufs()) do
      local keymaps = api.nvim_buf_get_keymap(bufnr, "n")
      for _, keymap in pairs(keymaps) do
        if keymap.lhs == "K" then
          table.insert(keymap_restore, keymap)
          api.nvim_buf_del_keymap(bufnr, "n", "K")
        end
      end
    end

    local hover_func =
      ":lua require('dap.ui.widgets').hover(nil, {border = dm.border[vim.g.border_style]})<CR>"
    nvim_set_keymap("n", "K", hover_func, { noremap = true, silent = true })
  end

  dap.listeners.after["event_terminated"]["dm"] = function()
    for _, keymap in pairs(keymap_restore) do
      api.nvim_buf_set_keymap(
        keymap.buffer,
        keymap.mode,
        keymap.lhs,
        keymap.rhs,
        { noremap = keymap.noremap == 1, silent = keymap.silent == 1 }
      )
    end
    keymap_restore = {}
  end
end

require("dapui").setup {
  icons = {
    expanded = "▾",
    collapsed = "▸",
  },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>", "<Space>" },
    open = "o",
    remove = "d",
    edit = "e",
  },
  sidebar = {
    open_on_start = true,
    elements = {
      "scopes",
      "breakpoints",
      "stacks",
      -- "watches",
    },
    width = 40,
    position = "left", -- Can be "left" or "right"
  },
  tray = {
    open_on_start = true,
    elements = {
      "repl",
    },
    height = 10,
    position = "bottom", -- Can be "bottom" or "top"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
  },
}
