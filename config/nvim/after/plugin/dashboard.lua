-- Personal start screen for Neovim written in Lua

local dashboard = require "dm.dashboard"

dm.augroup("dashboard", {
  {
    events = "VimEnter",
    targets = "*",
    modifiers = "++nested",
    command = function()
      if vim.fn.argc() == 0 and vim.fn.line2byte "$" == -1 then
        dashboard.open(true)
      end
    end,
  },
  {
    events = "VimResized",
    targets = "*",
    command = function()
      if vim.bo.filetype == "dashboard" then
        dashboard.open()
      end
    end,
  },
})

dm.command { "Dashboard", dashboard.open, attr = { "-bar" } }

dm.nnoremap { "<leader>`", "<Cmd>Dashboard<CR>" }
