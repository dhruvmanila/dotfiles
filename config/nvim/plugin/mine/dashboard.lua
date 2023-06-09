if vim.g.loaded_dashboard then
  return
end
vim.g.loaded_dashboard = true

local dashboard = require 'dm.dashboard'

-- Dashboard augroup id.
local id = vim.api.nvim_create_augroup('dm__dashboard', { clear = true })

vim.api.nvim_create_autocmd('User', {
  group = id,
  pattern = 'LazyVimStarted',
  callback = function()
    if
      vim.fn.argc() == 0
      and vim.fn.line2byte '$' == -1
      -- Do NOT open the dashboard when started without UI (`--headless`).
      and not vim.tbl_isempty(vim.api.nvim_list_uis())
    then
      dashboard.open(true)
    end
  end,
  desc = 'Open dashboard',
})

vim.api.nvim_create_autocmd('VimResized', {
  group = id,
  callback = function()
    if vim.bo.filetype == 'dashboard' then
      dashboard.open()
    end
  end,
  desc = 'Redraw the dashboard buffer',
})

vim.api.nvim_create_user_command('Dashboard', dashboard.open, {
  bar = true,
  desc = 'Open dashboard',
})

vim.keymap.set('n', ';d', '<Cmd>Dashboard<CR>')
