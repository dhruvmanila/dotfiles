if vim.g.loaded_dashboard then
  return
end
vim.g.loaded_dashboard = true

local dashboard = require 'dm.dashboard'
local utils = require 'dm.utils'

-- Dashboard augroup id.
local group = vim.api.nvim_create_augroup('dm__dashboard', { clear = true })

vim.api.nvim_create_autocmd('UIEnter', {
  group = group,
  callback = function()
    if vim.fn.argc() == 0 and utils.buf_is_empty() then
      dashboard.open()
    end
  end,
  desc = 'Open dashboard',
})

vim.api.nvim_create_autocmd('VimResized', {
  group = group,
  callback = function()
    if vim.bo.filetype == 'dashboard' then
      dashboard.open()
    end
  end,
  desc = 'Redraw the dashboard buffer',
})

vim.api.nvim_create_user_command('Dashboard', function()
  dashboard.open()
end, {
  bar = true,
  desc = 'Open dashboard',
})

vim.keymap.set('n', ';d', '<Cmd>Dashboard<CR>')
