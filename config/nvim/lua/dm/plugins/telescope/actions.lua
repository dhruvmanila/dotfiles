-- Custom Telescope actions.
local M = {}

local action_state = require 'telescope.actions.state'
local action_utils = require 'telescope.actions.utils'
local actions = require 'telescope.actions'

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
  actions.smart_send_to_qflist(prompt_bufnr)
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

-- Open the pull request associated with the selected Git commit.
---@param prompt_bufnr number
function M.git_open_commit_pull_request(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if selection == nil then
    return
  end

  actions.close(prompt_bufnr)
  local pr_number = (selection.msg or ''):match '%(#(%d+)%)$'
  if not pr_number then
    return
  end

  require('gitlinker').get_repo_url {
    action_callback = function(repo_url)
      vim.ui.open(('%s/pull/%s'):format(repo_url, pr_number))
    end,
    print_url = false,
  }
end

-- Open the current selection or all the selections made using multi-select
-- in the default browser.
---@param prompt_bufnr number
function M.open_in_browser(prompt_bufnr)
  local urls = {}
  action_utils.map_selections(prompt_bufnr, function(selection)
    urls[#urls + 1] = selection.url
  end)
  if vim.tbl_isempty(urls) then
    local selection = action_state.get_selected_entry()
    if selection == nil or selection.url == nil then
      return
    end
    urls[1] = selection.url
  end
  actions.close(prompt_bufnr)
  for _, url in ipairs(urls) do
    vim.ui.open(url)
  end
end

return M
