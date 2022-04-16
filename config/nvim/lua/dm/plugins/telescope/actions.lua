-- Custom Telescope actions.
local M = {}

local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local action_utils = require 'telescope.actions.utils'

-- Yank the selected entry or all the selections made using multi-selection
-- into the register pointed by the variable 'v:register' separated by newline.
---@param prompt_bufnr number
function M.yank_entry(prompt_bufnr)
  local values = {}
  action_utils.map_selections(prompt_bufnr, function(selection)
    values[#values + 1] = selection.value
  end)
  if vim.tbl_isempty(values) then
    table.insert(values, action_state.get_selected_entry().value)
  end
  values = vim.tbl_map(function(value)
    if type(value) == 'table' and value.text then
      value = value.text
    end
    return value
  end, values)
  vim.fn.setreg(vim.v.register, table.concat(values, '\n'))
end

-- Simple action to go to normal mode.
function M.stop_insert()
  vim.cmd 'stopinsert!'
end

-- Send the entries to the qflist and open the first entry and the quickfix
-- window in a new tab.
---@param prompt_bufnr number
function M.qflist_tab_session(prompt_bufnr)
  actions.smart_add_to_qflist(prompt_bufnr)
  vim.cmd 'tabnew | copen | cfirst'
end

-- Create a new branch if nothing is selected, else checkout the selected branch.
---@param prompt_bufnr number
function M.git_create_or_checkout_branch(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if selection == nil then
    actions.git_create_branch(prompt_bufnr)
  else
    actions.git_checkout(prompt_bufnr)
  end
end

-- Open the current selection or all the selections made using multi-select
-- in the default browser using `vim.g.open_command`.
---@param prompt_bufnr number
function M.open_in_browser(prompt_bufnr)
  local urls = ''
  action_utils.map_selections(prompt_bufnr, function(selection)
    urls = ('%s "%s"'):format(urls, selection.url)
  end)
  if urls == '' then
    urls = (' "%s"'):format(action_state.get_selected_entry().url)
  end
  if urls == '' then
    return
  end
  actions.close(prompt_bufnr)
  os.execute(vim.g.open_command .. urls)
end

return M
