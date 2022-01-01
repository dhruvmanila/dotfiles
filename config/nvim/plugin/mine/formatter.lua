-- Custom formatting setup using libUV
-- TODO: setup auto formatting per buffer using a buffer variable

if vim.g.loaded_formatter then
  return
end
vim.g.loaded_formatter = true

local format = require("dm.formatter.format").format

-- Flag to denote the current state of auto formatting.
local auto_formatting = false

-- Toggle between the two states of auto formatting.
local function toggle_auto_formatting()
  local commands = {}
  auto_formatting = not auto_formatting
  if auto_formatting then
    table.insert(commands, {
      events = "BufWritePost",
      targets = "*",
      command = format,
    })
  end
  dm.augroup("dm__auto_formatting", commands)
end

vim.api.nvim_add_user_command("ToggleAutoFormatting", toggle_auto_formatting, {
  force = true,
})
vim.api.nvim_add_user_command("Format", format, { force = true })

dm.nnoremap(";f", "<Cmd>Format<CR>")

-- By default, auto formatting is ON.
toggle_auto_formatting()
