local M = {}

-- Wrapper around `vim.api.nvim_set_hl` to set the global highlight group.
---@param group_name string
---@param args? table<string, any> Refer to |nvim_set_hl()|
function M.highlight(group_name, args)
  args = args or {}
  vim.api.nvim_set_hl(0, group_name, args)
end

-- Wrapper around `vim.api.nvim_set_hl` to link two highlight groups.
---@param from_group string
---@param to_group string
function M.link(from_group, to_group)
  vim.api.nvim_set_hl(0, from_group, { link = to_group })
end

return M
