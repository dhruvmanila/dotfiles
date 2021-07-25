local xnoremap = dm.xnoremap
local clipboard_action = require("dm.plugin.lir").clipboard_action

vim.cmd [[
setlocal nonumber
setlocal norelativenumber
setlocal nolist
]]

-- These additional mappings allow us to visually select multiple items and then
-- copy or cut them all at once. It is not a feature of lir itself but as the
-- plugin is quite extensible, I have a function defined which abstracts this out.
--
-- They need to be defined here as using the setup table only maps to normal mode.
xnoremap("C", function()
  clipboard_action("copy", "v")
end, { buffer = true })

xnoremap("X", function()
  clipboard_action("cut", "v")
end, { buffer = true })