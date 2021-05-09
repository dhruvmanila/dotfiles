local M = {}
local cmd = vim.api.nvim_command
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
    cmd("augroup " .. group_name)
    cmd("autocmd!")
    for _, command in ipairs(group_cmds) do
      cmd("autocmd " .. command)
    end
    cmd("augroup END")
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
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

---TODO: eventually move to using `nvim_set_hl` however for the time being
---that expects colors to be specified as rgb not hex.
---@param name string
---@param opts table
function M.highlight(name, opts)
  local force = opts.force or false
  if name and vim.tbl_count(opts) > 0 then
    if opts.link and opts.link ~= "" then
      vim.cmd(
        "highlight"
          .. (force and "!" or "")
          .. " link "
          .. name
          .. " "
          .. opts.link
      )
    else
      local hi_cmd = { "highlight", name }
      if opts.guifg and opts.guifg ~= "" then
        table.insert(hi_cmd, "guifg=" .. opts.guifg)
      end
      if opts.guibg and opts.guibg ~= "" then
        table.insert(hi_cmd, "guibg=" .. opts.guibg)
      end
      if opts.gui and opts.gui ~= "" then
        table.insert(hi_cmd, "gui=" .. opts.gui)
      end
      if opts.guisp and opts.guisp ~= "" then
        table.insert(hi_cmd, "guisp=" .. opts.guisp)
      end
      if opts.cterm and opts.cterm ~= "" then
        table.insert(hi_cmd, "cterm=" .. opts.cterm)
      end
      vim.cmd(table.concat(hi_cmd, " "))
    end
  end
end

---"Safe" version of `nvim_<|win|buf|tabpage>_get_var()` that returns `nil` if
---the variable is not set.
---@param scope string (g|w|b|t) (Default: g)
---@param handle integer
---@param name string
---@return nil|string
function M.get_var(scope, handle, name)
  local func, args
  scope = scope or "g"
  if scope == "g" then
    func, args = vim.api.nvim_get_var, { name }
  elseif scope == "w" then
    func, args = vim.api.nvim_win_get_var, { handle, name }
  elseif scope == "b" then
    func, args = vim.api.nvim_buf_get_var, { handle, name }
  elseif scope == "t" then
    func, args = vim.api.nvim_tabpage_get_var, { handle, name }
  end

  local ok, result = pcall(func, unpack(args))
  if ok then
    return result
  end
end

---Return the current working directory using the following given root pattern.
---Default: Current working directory
---@param pattern table (Default: {'.git', 'requirements.txt'})
---@return string
function M.get_project_root(pattern)
  local ok, util = pcall(require, "lspconfig.util")

  if ok then
    pattern = pattern or { ".git", "requirements.txt" }
    return util.root_pattern(pattern)(vim.fn.expand("%")) or vim.loop.cwd()
  else
    return vim.loop.cwd()
  end
end

---Emit a warning message.
---@param msg string
function M.warn(msg)
  vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
end

return M
