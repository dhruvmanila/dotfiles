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

-- Return true if the current filepath is in any of the given project names,
-- false otherwise.
---@param ... string
---@return boolean
local function ignore_projects(...)
  local path = vim.api.nvim_buf_get_name(0)
  for i = 1, select("#", ...) do
    if path:find(select(i, ...), 1, true) then
      return true
    end
  end
  return false
end

vim.api.nvim_add_user_command("ToggleAutoFormatting", toggle_auto_formatting, {
  force = true,
})
vim.api.nvim_add_user_command("Format", format, { force = true })

vim.keymap.set("n", ";f", "<Cmd>Format<CR>")

-- Auto formatting is ON except for some projects.
if not ignore_projects("infogami", "openlibrary", "thoucentric") then
  toggle_auto_formatting()
end
