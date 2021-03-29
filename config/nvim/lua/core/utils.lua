local M = {}
local cmd = vim.cmd
local nvim_set_keymap = vim.api.nvim_set_keymap

-- Helper function to set the neovim options until #13479 merges.
--
-- This will make sure each option is set to the respective scope.
-- Ref: https://github.com/ellisonleao/dotfiles/blob/main/configs/.config/nvim/lua/editor.lua#L40
M.opt = setmetatable({}, {
  __index = vim.o,
  __newindex = function(_, key, value)
    vim.o[key] = value
    local scope = vim.api.nvim_get_option_info(key).scope
    if scope == "win" then
      vim.wo[key] = value
    elseif scope == "buf" then
      vim.bo[key] = value
    end
  end,
})


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
