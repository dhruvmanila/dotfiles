local icons = require('core.icons').icons
local utils = require('core.utils')

-- Extract out the required namespace/function
local vim = vim
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local M = {}

--- Useful defaults
local empty_line = {''}

-- Dashboard namespace
local dashboard = {}

-- Dashboard buffer/window options
dashboard.opts = {
  bufhidden = 'wipe',
  buflisted = false,
  colorcolumn = '',
  foldcolumn = '0',
  matchpairs = '',
  modifiable = true,
  cursorcolumn = false,
  cursorline = false,
  list = false,
  number = false,
  readonly = false,
  relativenumber = false,
  spell = false,
  swapfile = false,
  signcolumn = 'no',
}

--- Add the key value to the right end of the given line with the appropriate
--- padding as per the `length` value.
---@param line table
---@param key string
---@param length number
---@return table
local function add_key(line, key, length)
  return {line[1] .. string.rep(" ", length - #line[1]) .. key}
end

--- Last session entry description.
local function last_session_description()
  local path = fn.resolve(vim.g.neovim_session_dir .. '/__LAST__')
  local name = fn.fnamemodify(path, ':t')
  return {icons.pin .. '  Last session (' .. name ..')'}
end

--- Generate and return the header of the start page.
---@return table
local function generate_header()
  local v = vim.version()
  v = 'v' .. v.major .. '.' .. v.minor .. '.' .. v.patch

  return {
    '',
    '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
    '',
    '                  Neovim ' .. v .. '',
    '',
    '',
  }
end

--- Dashboard sections. Every element is a dictionary with the following keys:
---   - `key`: (string) used to create a keymap to trigger `command`
---   - `description`: (string|function) display this on the start page
---   - `command`: (string|function) execute the command on pressing `key`
local entries = {
  {
    key = 'l',
    description = last_session_description,
    command = 'SLoad!',
  },
  {
    key = 's',
    description = {icons.globe .. '  Find sessions'},
    command = "lua require('plugin.telescope').startify_sessions()",
  },
  {
    key = 'h',
    description = {icons.history .. '  Recently opened files'},
    command = 'Telescope oldfiles',
  },
  {
    key = 'f',
    description = {icons.file .. '  Find files'},
    command = "lua require('plugin.telescope').find_files()",
  },
  {
    key = 'p',
    description = {icons.stopwatch .. '  Startup time'},
    command = 'StartupTime',
  },
}

--- Generate and return the footer of the start page.
---@return table
local function generate_footer()
  local loaded_plugins = #vim.tbl_filter(function(plugin)
    return plugin.loaded
  end, _G.packer_plugins)

  return {
    '',
    '',
    'Neovim loaded ' .. loaded_plugins .. ' plugins',
    '',
  }
end

--- Append the given lines in the current buffer. If `hl` is provided then add
--- the given highlight group to the respective lines.
---@param lines table
---@param hl string
local function append(lines, hl)
  local linenr = api.nvim_buf_line_count(0)
  api.nvim_buf_set_lines(0, linenr, linenr, false, lines)
  if hl then
    for idx = linenr, linenr + #lines do
      api.nvim_buf_add_highlight(0, -1, hl, idx, 1, -1)
    end
  end
end

--- Add paddings on the left side of every line to make it look like its in the
--- center of the current window.
---@param lines table
---@return table
local function center(lines)
  local longest_line = math.max(unpack(vim.tbl_map(function(line)
    return api.nvim_strwidth(line)
  end, lines)))

  local shift = math.floor(api.nvim_win_get_width(0) / 2 - longest_line / 2)

  return vim.tbl_map(function(line)
    return string.rep(" ", shift) .. line
  end, lines)
end

--- Perform either of the three process for the given/saved options:
---   - set the given options
---   - save the option values for the given `opts` in `saved_opts` table
---@param opts table|nil
---@param process string - set|save
local function option_process(opts, process)
  if process == "set" then
    for name, value in pairs(opts) do
      local scope = api.nvim_get_option_info(name).scope
      api["nvim_" .. scope .. "_set_option"](0, name, value)
    end
  elseif process == "save" then
    for name, _ in pairs(opts) do
      local scope = api.nvim_get_option_info(name).scope
      dashboard.saved_opts[name] = api["nvim_" .. scope .. "_get_option"](0, name)
    end
  else
    error("Unknown 'process' value: " .. process)
  end
end

--- Register the entry into the dashboard table for the current line
---@param entry table
local function register_entry(entry)
  local line = api.nvim_buf_line_count(0)
  dashboard.entries[line] = {
    line = line,
    key = entry.key,
    command = entry.command,
  }
end

--- Set the entries in the UI and register it in the dashboard table.
local function set_entries()
  for _, entry in ipairs(entries) do
    local description = entry.description
    description = type(description) == 'function' and description() or description
    description = add_key(description, entry.key, 50)
    append(center(description), 'Red')
    register_entry(entry)
    append(empty_line)
  end
end

--- Set the required mappings which includes:
---   - <CR>: open the entry at the current cursor position
---   - q: quit the dashboard buffer
---   - `key`: open the entry for the registered entry
local function set_mappings()
  local buf_map = api.nvim_buf_set_keymap
  local opts = {noremap = true, silent = true, nowait = true}

  -- Basic keymap
  buf_map(0, 'n', 'e', '<Cmd>enew<CR>', opts)
  buf_map(0, 'n', '<CR>', "<Cmd>lua require('core.dashboard').open_entry()<CR>", opts)
  buf_map(0, 'n', 'q', "<Cmd>lua require('core.dashboard').close()<CR>", opts)

  -- Registered entries
  for line, entry in pairs(dashboard.entries) do
    buf_map(0, 'n', entry.key, "<Cmd>lua require('core.dashboard').open_entry(" .. line .. ")<CR>", opts)
  end
end

--- Reset the saved options
function M.reset_opts()
  option_process(dashboard.saved_opts, 'set')
  dashboard.saved_opts = {}
end

--- Cleanup performed before saving the session. This includes:
---   - Closing the NvimTree buffer
---   - Quitting the Dashboard buffer
function M.session_cleanup()
  if api.nvim_buf_get_option(0, 'filetype') == 'dashboard' then
    local calling_buffer = fn.bufnr('#')
    if calling_buffer > 0 then
      api.nvim_set_current_buf(calling_buffer)
    end
  end

  if _G.packer_plugins['nvim-tree.lua'].loaded then
    local curtab = api.nvim_get_current_tabpage()
    cmd('silent tabdo NvimTreeClose')
    api.nvim_set_current_tabpage(curtab)
  end
end

--- Close the dashboard buffer and either quit neovim or move back to the
--- original buffer.
function M.close()
  local buflisted = vim.tbl_filter(function(bufnr)
    return fn.buflisted(bufnr) == 1
  end, api.nvim_list_bufs())

  if #buflisted ~= 0 then
    if api.nvim_buf_is_loaded(fn.bufnr('#')) and fn.bufnr('#') ~= fn.bufnr('%') then
      cmd('buffer #')
    else
      cmd('bnext')
    end
  else
    cmd('quit')
  end
end

--- Open the entry as per the given `line`. If `line` is `nil`, then open the
--- entry at the cursor position (coming from pressing <CR>), otherwise open
--- the entry at the given line (coming from pressing `key`).
---@param line nil|number
function M.open_entry(line)
  line = line or api.nvim_win_get_cursor(0)[1]
  local entry = dashboard.entries[line]
  local command_type = type(entry.command)

  if command_type == "function" then
    entry.command()
  elseif command_type == "string" then
    cmd(entry.command)
  else
    utils.warn("[dashboard] Unsupported 'command' type: " .. command_type)
  end
end

--- Set the cursor position according to the current dashboard information
--- mainly the `oldline` and `newline` position.
function M.set_cursor()
  local oldline  = dashboard.newline
  local newline, col = unpack(api.nvim_win_get_cursor(0))
  local fixed_column = dashboard.fixed_column

  -- Direction: right (+1), left (-1), up (-1), down (+1)
  local movement
  if oldline == newline and col ~= fixed_column then
    movement = 2 * (col > fixed_column and 1 or 0) - 1
    newline = newline + movement
  else
    movement = 2 * (newline > oldline and 1 or 0) - 1
  end

  -- Skip blank lines between entries
  if fn.empty(api.nvim_buf_get_lines(0, newline, newline + 1, false)[1]) then
    newline = newline + movement
  end

  -- Don't go beyond first or last entry
  newline = math.max(dashboard.firstline, math.min(dashboard.lastline, newline))

  -- Update the numbers and the cursor position
  dashboard.oldline = oldline
  dashboard.newline = newline
  api.nvim_win_set_cursor(0, {newline, fixed_column})
end

--- Open the dashboard buffer in the current buffer if it is empty or create
--- a new buffer for the current window.
function M.open(on_vimenter)
  if on_vimenter and (vim.o.insertmode or not vim.o.modifiable) then
    return
  end

  if not vim.o.hidden and vim.o.modified then
    utils.warn("[dashboard] Please save your changes first.")
    return
  end

  -- Save the current window/buffer options
  dashboard.saved_opts = {}
  option_process(dashboard.opts, 'save')

  -- Create a new, unnamed buffer
  if fn.line2byte('$') ~= -1 then
    local bufnr = api.nvim_create_buf(false, true)
    api.nvim_win_set_buf(0, bufnr)
  end

  -- Set the dashboard buffer options
  option_process(dashboard.opts, 'set')

  -- Set the header
  local header = generate_header()
  append(empty_line)
  append(center(header), 'Yellow')
  append(empty_line)

  -- Set the sections
  dashboard.entries = {}
  set_entries()
  api.nvim_buf_set_lines(0, -2, -1, false, {})

  -- Compute first and last line offset
  --
  -- `nvim_buf_set_lines`
  -- uses zero-based index
  --     |             empty line           empty line
  --     |                  | header lines       |
  --     +--------------+   |      |      +------+
  --                    |   |      |      |
  dashboard.firstline = 1 + 2 + #header + 1
  dashboard.lastline = api.nvim_buf_line_count(0)

  -- Set the footer
  append(empty_line)
  append(center(generate_footer()), 'Blue')

  -- Lock the buffer
  option_process({
    modifiable = false,
    modified = false,
    filetype = 'dashboard'
  }, 'set')

  api.nvim_buf_set_name(0, 'Dashboard')
  set_mappings()

  -- Initially, the newline will be the firstline
  dashboard.newline = dashboard.firstline
  api.nvim_win_set_cursor(0, {dashboard.firstline, 0})

  -- Fix column position to the first letter of the second word (skipping
  -- the icon)
  cmd('normal! ^ w')
  dashboard.fixed_column = api.nvim_win_get_cursor(0)[2]

  cmd("autocmd dashboard CursorMoved <buffer> lua require('core.dashboard').set_cursor()")
  cmd("autocmd dashboard BufWipeout dashboard ++once lua require('core.dashboard').reset_opts()")
  cmd('silent! %foldopen!')
  cmd('normal! zb')
end

-- For debugging purposes
M._dashboard = dashboard

return M
