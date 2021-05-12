local M = {}
local api = vim.api
local cmd = api.nvim_command
local icons = require("core.icons")

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
---@param opts table<string, boolean|string>
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
---@param scope string Available: g|w|b|t (Default: g)
---@param handle integer
---@param name string
---@return nil|any
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

-- Return the current working directory using the given root pattern. Defaults
-- to the current working directory if the root pattern is not found.
---@param pattern string[] Default: {'.git', 'requirements.txt'}
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
---@return nil
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
---@param opts table<string, number>
---@return nil
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

-- Simplified version of `vim.lsp.util.make_floating_popup_options`
-- This will consider the number of columns from the left end of neovim instead
-- of the current window.
---@param width number width of the popup window
---@param height number height of the popup window
---@return table @opts table to be passed to `vim.api.nvim_open_win`
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

  local col_left = api.nvim_win_get_position(0)[2] + vim.fn.wincol() + width
  if col_left <= api.nvim_get_option("columns") then
    anchor = anchor .. "W"
    col = 0
  else
    anchor = anchor .. "E"
    col = 1
  end

  return {
    relative = "cursor",
    anchor = anchor,
    height = height,
    width = width,
    row = row,
    col = col,
    style = "minimal",
  }
end

-- Child window offset for the respective anchor position. This is used to
-- add an appropriate offset to `row` and `col` field for the child window
-- with respect to the parent border window.
local child_win_offset = {
  NW = { 1, 1 },
  NE = { 1, -1 },
  SW = { -1, 1 },
  SE = { -1, -1 },
}

---@class BorderedWindowOpts
---@field width number
---@field height number
---@field title string
---@field highlight string
---@field border string[]

local function cleanup_autocmds(border_bufnr, child_bufnr)
  M.create_augroups({
    bordered_window_cleanup = {
      string.format(
        "BufWipeout,BufDelete <buffer=%d> execute 'bw %d | stopinsert'",
        child_bufnr,
        border_bufnr
      ),
      -- string.format(
      --   "WinLeave <buffer=%d> "
      -- )
    },
  })
end

-- Helper function to create the appropriate border lines for a floating
-- popup window.
---@param opts BorderedWindowOpts
---@return string[]
local function create_border(opts)
  local border = opts.border or icons.border.default
  local title = opts.title and " " .. opts.title .. " " or ""

  local top = string.format(
    "%s%s%s%s",
    border[1],
    title,
    string.rep(border[2], opts.width - #title),
    border[3]
  )

  local mid = string.format(
    "%s%s%s",
    border[8],
    string.rep(" ", opts.width),
    border[4]
  )

  local bot = string.format(
    "%s%s%s",
    border[7],
    string.rep(border[6], opts.width),
    border[5]
  )

  local lines = {}
  table.insert(lines, top)
  for _ = 1, opts.height do
    table.insert(lines, mid)
  end
  table.insert(lines, bot)

  return lines
end

---@param opts BorderedWindowOpts
-- Following keys are valid:
--   - `width` (number) window width, excluding the border
--   - `height` (number) window height, excluding the border
--   - `title` (string) (optional) window title, displayed in the border
--   - `highlight` (string) (optional) border highlights
--   - `border` (string[]) (optional) border characters in clockwise order
--      starting from top left corner.
---@return number @main window handle
---@return number @main window's buffer number
---@return table @border table containing one key: `winnr`
function M.bordered_window(opts)
  local border_lines = create_border(opts)
  local border_bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(border_bufnr, "bufhidden", "wipe")
  api.nvim_buf_set_lines(border_bufnr, 0, -1, false, border_lines)

  -- border window, content width + 2 border
  local win_opts = M.make_floating_popup_options(opts.width + 2, #border_lines)
  win_opts.focusable = false
  local border_winnr = api.nvim_open_win(border_bufnr, false, win_opts)
  local hl = opts.highlight or "FloatBorder"
  api.nvim_win_set_option(border_winnr, "winhl", "NormalFloat:" .. hl)

  -- child window
  local row_offset, col_offset = unpack(child_win_offset[win_opts.anchor])
  win_opts.width = opts.width
  win_opts.height = opts.height
  win_opts.row = win_opts.row + row_offset
  win_opts.col = win_opts.col + col_offset
  win_opts.focusable = true

  local bufnr = api.nvim_create_buf(false, true)
  local winnr = api.nvim_open_win(bufnr, true, win_opts)
  cleanup_autocmds(border_bufnr, bufnr)
  return winnr, bufnr, { winnr = border_winnr }
end

return M
