-- Custom formatting setup using libUV
-- TODO: setup auto formatting per buffer using a buffer variable

if vim.g.loaded_formatter then
  return
end
vim.g.loaded_formatter = true

local format = require('dm.formatter').format

-- Flag to denote the current state of auto formatting.
local auto_formatting = false

-- Toggle between the two states of auto formatting.
local function toggle_auto_formatting()
  auto_formatting = not auto_formatting
  -- Clear the autocmds for the auto formatting group.
  local id = vim.api.nvim_create_augroup('dm__auto_formatting', {
    clear = true,
  })
  if auto_formatting then
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = id,
      callback = format,
      desc = 'Format the buffer',
    })
  end
end

-- Return true if the current filepath is in any of the given project names,
-- false otherwise.
---@param ... string
---@return boolean
local function ignore_projects(...)
  local cwd = vim.loop.cwd():lower()
  for i = 1, select('#', ...) do
    if cwd:find(select(i, ...), 1, true) then
      return true
    end
  end
  return false
end

vim.api.nvim_create_user_command(
  'ToggleAutoFormatting',
  toggle_auto_formatting,
  {}
)
vim.api.nvim_create_user_command('Format', format, {})

vim.keymap.set('n', ';f', '<Cmd>Format<CR>')

-- Auto formatting is ON except for some projects.
if not ignore_projects 'thoucentric' then
  toggle_auto_formatting()
end
