local api = vim.api
local nnoremap = dm.nnoremap

local dap = require "dap"
local dap_python = require "dap-python"

-- Add configurations from `.vscode/launch.json` file
require("dap.ext.vscode").load_launchjs()

vim.fn.sign_define {
  { name = "DapBreakpoint", text = "", texthl = "Orange" },
  { name = "DapStopped", text = "", texthl = "TabLineSel" },
}

dap_python.test_runner = "pytest"
dap_python.setup(vim.loop.os_homedir() .. "/.neovim/py3/bin/python3", {
  include_configs = true,
})

nnoremap("<leader>dl", dap.run_last)
nnoremap("<leader>dc", dap.continue)
nnoremap("<leader>ds", dap.step_over)
nnoremap("<leader>di", dap.step_into)
nnoremap("<leader>do", dap.step_out)
nnoremap("<leader>dr", dap.repl.toggle)
nnoremap("<leader>db", dap.toggle_breakpoint)

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

    nnoremap("K", function()
      require("dap.ui.widgets").hover(
        nil,
        { border = dm.border[vim.g.border_style] }
      )
    end)
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
  mappings = {
    expand = { "<CR>", "<2-LeftMouse>", "<Space>" },
  },
  sidebar = {
    open_on_start = true,
    elements = {
      { id = "scopes", size = 0.6 },
      { id = "breakpoints", size = 0.2 },
      { id = "stacks", size = 0.2 },
    },
  },
}
