if vim.g.loaded_dashboard then
  return
end
vim.g.loaded_dashboard = true

local dashboard = require "dm.dashboard"

dm.augroup("dm__dashboard", {
  {
    events = "VimEnter",
    targets = "*",
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

dm.command("Dashboard", dashboard.open, { bar = true })

dm.nnoremap(";d", "<Cmd>Dashboard<CR>")
