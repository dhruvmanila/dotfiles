local M = {}
local api = vim.api
local cmd = api.nvim_command

-- Emit a warning message.
---@param msg string
function M.warn(msg)
  api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
end

-- Helper function to set the neovim options until #13479 merges.
--
-- This will make sure each option is set to the respective scope.
-- Ref: https://github.com/ellisonleao/dotfiles/blob/main/configs/.config/nvim/lua/editor.lua#L40
M.opt = setmetatable({}, {
  __index = vim.o,
  __newindex = function(_, key, value)
    vim.o[key] = value
    local scope = api.nvim_get_option_info(key).scope
    if scope == "win" then
      vim.wo[key] = value
    elseif scope == "buf" then
      vim.bo[key] = value
    end
  end,
})

-- Create autocommand groups based on the given definitions.
---@param definitions table<string, string[]>
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
--   opts.noremap = true, if not defined in opts
--
---@param modes string|string[]
---@param lhs string
---@param rhs string
---@param opts table (optional)
function M.map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

-- TODO: eventually move to using `nvim_set_hl` however for the time being
-- that expects colors to be specified as rgb not hex.
---@param name string
---@param opts table
function M.highlight(name, opts)
  local force = opts.force or false
  if name and vim.tbl_count(opts) > 0 then
    if opts.link and opts.link ~= "" then
      cmd(
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
      cmd(table.concat(hi_cmd, " "))
    end
  end
end

-- "Safe" version of `nvim_<|win|buf|tabpage>_get_var()` that returns `nil` if
-- the variable is not set.
---@param scope string (g|w|b|t) (Default: g)
---@param handle integer
---@param name string
---@return nil|string
function M.get_var(scope, handle, name)
  local func, args
  scope = scope or "g"
  if scope == "g" then
    func, args = api.nvim_get_var, { name }
  elseif scope == "w" then
    func, args = api.nvim_win_get_var, { handle, name }
  elseif scope == "b" then
    func, args = api.nvim_buf_get_var, { handle, name }
  elseif scope == "t" then
    func, args = api.nvim_tabpage_get_var, { handle, name }
  end

  local ok, result = pcall(func, unpack(args))
  if ok then
    return result
  end
end

-- Return the current working directory using the following given root pattern.
-- Default: Current working directory
---@param pattern string[] (Default: {'.git', 'requirements.txt'})
---@return string
function M.get_project_root(pattern)
  local ok, util = pcall(require, "lspconfig.util")
  local default_pattern = { ".git", "requirements.txt" }

  if ok then
    pattern = vim.list_extend(pattern or {}, default_pattern)
    return util.root_pattern(pattern)(vim.fn.expand("%")) or vim.loop.cwd()
  else
    return vim.loop.cwd()
  end
end

-- Append the given lines in the provided bufnr, defaults to the current buffer.
-- If `hl` is provided then add the given highlight group to the respective lines.
---@param bufnr number
---@param lines string[]
---@param hl string
function M.append(bufnr, lines, hl)
  bufnr = bufnr or api.nvim_get_current_buf()
  local linenr = api.nvim_buf_line_count(bufnr) - 1
  api.nvim_buf_set_lines(bufnr, linenr, linenr, false, lines)
  if hl then
    for idx = linenr, linenr + #lines do
      api.nvim_buf_add_highlight(bufnr, -1, hl, idx, 0, -1)
    end
  end
end

-- Fixed column cursor movements with line limits. This will skip any blank
-- lines in between. This should only be used in autocmds with CursorHold event.
-- `opts` table expects the followings keys to be present:
--   - firstline (number) Upper row limit
--   - lastline (number) Lower row limit
--   - fixed_column (number) Column to fix the cursor at
--   - newline (number) Current cursor line
-- Internal:
--   - oldline (number) Previous cursor line
---@param opts table
function M.fixed_column_movement(opts)
  local oldline = opts.newline
  local newline = api.nvim_win_get_cursor(0)[1]

  -- Direction: up (-1) or down (+1) (no horizontal movements are registered)
  local movement = 2 * (newline > oldline and 1 or 0) - 1

  -- Skip blank lines between entries
  if api.nvim_buf_get_lines(0, newline - 1, newline, false)[1] == "" then
    newline = newline + movement
  end

  -- Don't go beyond first or last entry
  newline = math.max(opts.firstline, math.min(opts.lastline, newline))

  -- Update the numbers and the cursor position
  opts.oldline = oldline
  opts.newline = newline
  api.nvim_win_set_cursor(0, { newline, opts.fixed_column })
end

function M.make_floating_popup_options(width, height)
  local anchor = ""
  local row, col

  local lines_above = vim.fn.winline() - 1
  local lines_below = vim.fn.winheight(0) - lines_above

  if lines_above < lines_below then
    anchor = anchor .. "N"
    height = math.min(lines_below, height)
    row = 1
  else
    anchor = anchor .. "S"
    height = math.min(lines_above, height)
    row = 0
  end

  local offset_y = vim.fn.wincol() + width
  if
    offset_y <= api.nvim_get_option("columns")
    and offset_y <= api.nvim_win_get_width(0)
  then
    anchor = anchor .. "W"
    col = 0
  else
    anchor = anchor .. "E"
    col = 1
  end

  return {
    anchor = anchor,
    col = col,
    height = height,
    relative = "cursor",
    row = row,
    style = "minimal",
    width = width,
  }
end

return M
