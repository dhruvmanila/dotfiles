local M = {}
local cmd = vim.cmd
local nvim_set_keymap = vim.api.nvim_set_keymap

-- Create autocommand groups based on the given definitions.
--
-- @param definitions table<string, string[]>
function M.create_augroups(definitions)
  for group_name, group_cmds in pairs(definitions) do
    cmd('augroup ' .. group_name)
    cmd('autocmd!')
    for _, command in ipairs(group_cmds) do
      cmd('autocmd ' .. command)
    end
    cmd('augroup END')
  end
end

-- Create key bindings for multiple modes with an optional parameters map.
-- Defaults:
--   opts = {}, if not given
--   opts.noremap = true, if not defined in opts
--
-- @param modes (string or list of strings)
-- @param lhs (string)
-- @param rhs (string)
-- @param opts (optional table)
function M.map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == 'string' then
    modes = {modes}
  end
  for _, mode in ipairs(modes) do
    nvim_set_keymap(mode, lhs, rhs, opts)
  end
end


return M
