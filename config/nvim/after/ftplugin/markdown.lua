vim.cmd [[
setlocal textwidth=80
]]

dm.command(
  "Preview",
  require("dm.markdown").preview,
  { bar = true, buffer = true }
)
