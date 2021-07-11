local utils = require "dm.utils"

-- Extract out the required namespace/function
local vim = vim
local o = vim.o
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local M = {}

--- Useful defaults
local empty_line = { "" }
local line_length = 50
local hl = { header = "Yellow", entry = "Red", footer = "Blue" }

-- Dashboard namespace
local dashboard = {}

-- Dashboard buffer/window options
dashboard.opts = {
  bufhidden = "wipe",
  colorcolumn = "",
  foldcolumn = "0",
  matchpairs = "",
  modifiable = true,
  cursorcolumn = false,
  cursorline = false,
  list = false,
  number = false,
  readonly = false,
  relativenumber = false,
  spell = false,
  swapfile = false,
  signcolumn = "no",
}

--- Last session entry description.
--- This also sets the global variable `startify_last_session_name` to be used
--- to load the session.
---@return string[]
local function last_session_description()
  local last_session = ""
  local last_edited = 0
  local session_dir = vim.g.startify_session_dir

  for _, name in ipairs(fn.readdir(session_dir)) do
    if name ~= "__LAST__" then
      local path = session_dir .. "/" .. name
      local time = fn.getftime(path)
      if time > last_edited then
        last_session = name
        last_edited = time
      end
    end
  end

  vim.g.startify_last_session_name = last_session
  return "  Last session (" .. last_session .. ")"
end

--- Generate and return the header of the start page.
---@return string[]
local function generate_header()
  return {
    "",
    "",
    "███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
    "████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
    "██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
    "██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
    "██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
  }
end

---@return string[]
local function generate_sub_header()
  -- local v = vim.version()
  -- v = "v" .. v.major .. "." .. v.minor .. "." .. v.patch
  local v = fn.split(fn.split(api.nvim_exec("version", true), "\n")[1])[2]
  return { v, "", "" }
end

---@class DashboardEntry
---@field key string keymap to trigger the `command`
---@field description string|fun():string oneline command description
---@field command string|function execute the string/function on `key` or `<CR>`

---@type DashboardEntry[]
local entries = {
  {
    key = "l",
    description = last_session_description,
    command = "call startify#session_load(0, g:startify_last_session_name)",
  },
  {
    key = "s",
    description = "  Find sessions",
    command = 'lua require("dm.plugin.telescope").startify_sessions()',
  },
  { key = "e", description = "  New file", command = "enew" },
  {
    key = "h",
    description = "  Recently opened files",
    command = 'lua require("telescope.builtin").oldfiles()',
  },
  {
    key = "f",
    description = "  Find files",
    command = 'lua require("telescope.builtin").find_files()',
  },
  {
    key = "d",
    description = "  Find in dotfiles",
    command = 'lua require("dm.plugin.telescope").find_dotfiles()',
  },
  {
    key = "u",
    description = "  Sync packages",
    command = "PackerSync",
  },
  {
    key = "p",
    description = "  Startup time",
    command = utils.startuptime,
  },
}

--- Generate and return the footer of the start page.
---@return string[]
local function generate_footer()
  local loaded_plugins = #vim.tbl_filter(
    plugin_loaded,
    vim.tbl_keys(_G.packer_plugins)
  )
  return { "", "", "Neovim loaded " .. loaded_plugins .. " plugins", "" }
end

--- Add the key value to the right end of the given line with the appropriate
--- padding as per the `length` value.
---@param line string
---@param key string
---@return string
local function add_key(line, key)
  return line .. string.rep(" ", line_length - #line) .. key
end

--- Add paddings on the left side of every line to make it look like its in the
--- center of the current window.
---@param lines string[]
---@return string[]
local function center(lines)
  local longest_line = math.max(unpack(vim.tbl_map(function(line)
    return api.nvim_strwidth(line)
  end, lines)))

  local shift = math.floor(api.nvim_win_get_width(0) / 2 - longest_line / 2)

  return vim.tbl_map(function(line)
    return string.rep(" ", shift) .. line
  end, lines)
end

---@alias Process
---|'"set"' # set the options using the `opts` table
---|'"save"' # save the option values for the given `opts` table
---@param opts? table<string, any>
---@param process Process
local function option_process(opts, process)
  for name, value in pairs(opts) do
    dm.case(process, {
      ["set"] = function()
        vim.opt_local[name] = value
      end,
      ["save"] = function()
        dashboard.saved_opts[name] = vim.opt_local[name]:get()
      end,
    })
  end
end

--- Register the entry into the dashboard table for the current line
---@param entry DashboardEntry
local function register_entry(entry)
  local line = api.nvim_buf_line_count(0) - 1
  dashboard.entries[line] = {
    line = line,
    key = entry.key,
    command = entry.command,
  }
end

--- Set the entries in the UI and register it in the dashboard namespace.
local function set_entries()
  for _, entry in ipairs(entries) do
    local description = entry.description
    if type(description) == "function" then
      description = description()
    end
    description = add_key(description, entry.key)
    utils.append(0, center { description }, hl.entry)
    register_entry(entry)
    utils.append(0, empty_line)
  end
end

--- Set the required mappings which includes:
---   - <CR>: open the entry at the current cursor position
---   - q: quit the dashboard buffer
---   - `key`: open the entry for the registered entry
local function set_mappings()
  local buf_map = api.nvim_buf_set_keymap
  local opts = { noremap = true, silent = true, nowait = true }

  -- Registered entries
  for line, entry in pairs(dashboard.entries) do
    local entry_fn = string.format(
      "<Cmd>lua require('dm.dashboard').open_entry(%d)<CR>",
      line
    )
    buf_map(0, "n", entry.key, entry_fn, opts)
  end

  -- Basic keymap
  local entry_fn = "<Cmd>lua require('dm.dashboard').open_entry()<CR>"
  local close_fn = "<Cmd>lua require('dm.dashboard').close()<CR>"
  buf_map(0, "n", "<CR>", entry_fn, opts)
  buf_map(0, "n", "q", close_fn, opts)
end

--- Reset the saved options
local function reset_opts()
  option_process(dashboard.saved_opts, "set")
  dashboard.saved_opts = {}
end

--- Cleanup performed before saving the session. This includes:
---   - Closing the NvimTree buffer
---   - Quitting the Dashboard buffer
---   - Stop all the active LSP clients
function M.session_cleanup()
  if o.filetype == "dashboard" then
    local calling_buffer = fn.bufnr "#"
    if calling_buffer > 0 then
      api.nvim_set_current_buf(calling_buffer)
    end
  end

  if plugin_loaded "nvim-tree.lua" then
    local curtab = api.nvim_get_current_tabpage()
    cmd "silent tabdo NvimTreeClose"
    api.nvim_set_current_tabpage(curtab)
  end

  vim.lsp.stop_client(vim.lsp.get_active_clients())
end

--- Close the dashboard buffer and either quit neovim or move back to the
--- original buffer.
function M.close()
  local curbuflisted = fn.buflisted(api.nvim_get_current_buf())
  local buflisted = vim.tbl_filter(function(bufnr)
    return fn.buflisted(bufnr) == 1
  end, api.nvim_list_bufs())

  if #buflisted - curbuflisted ~= 0 then
    if
      api.nvim_buf_is_loaded(fn.bufnr "#")
      and fn.bufnr "#" ~= fn.bufnr "%"
    then
      cmd "buffer #"
    else
      cmd "bnext"
    end
  else
    cmd "quit"
  end
end

--- Open the entry as per the given `line`. If `line` is `nil`, then open the
--- entry at the cursor position (coming from pressing <CR>), otherwise open
--- the entry at the given line (coming from pressing `key`).
---@param line? number
function M.open_entry(line)
  line = line or api.nvim_win_get_cursor(0)[1]
  local entry = dashboard.entries[line]
  local command = entry.command

  dm.case(type(command), {
    ["function"] = command,
    ["string"] = function()
      cmd(command)
    end,
  })
end

--- Open the dashboard buffer in the current buffer if it is empty or create
--- a new buffer for the current window.
function M.open(on_vimenter)
  if on_vimenter and (o.insertmode or not o.modifiable) then
    return
  end

  if not o.hidden and o.modified then
    vim.notify({ "Dashboard", "", "Please save your changes first" }, 3)
    return
  end

  -- We will ignore all events while creating the dashboard buffer as it might
  -- result in unintended effect when dashboard is called in a nested fashion.
  o.eventignore = "all"

  -- Save the current window/buffer options
  -- If we are being called from a dashboard buffer, then we should not save
  -- the options as it will save the dashboard buffer specific options.
  if o.filetype ~= "dashboard" then
    dashboard.saved_opts = {}
    option_process(dashboard.opts, "save")
  end

  -- Create a new, unnamed buffer
  if fn.line2byte "$" ~= -1 then
    local bufnr = api.nvim_create_buf(true, true)
    -- If we are being called from a dashboard buffer in a nested fashion, we
    -- should keep the alternate buffer which is the one we go to when we
    -- quit the dashboard buffer.
    if o.filetype == "dashboard" then
      cmd(string.format("keepalt call nvim_win_set_buf(0, %d)", bufnr))
    else
      api.nvim_win_set_buf(0, bufnr)
    end
  end

  -- Set the dashboard buffer options
  option_process(dashboard.opts, "set")

  -- Set the header
  local header = generate_header()
  local sub_header = generate_sub_header()
  utils.append(0, empty_line)
  utils.append(0, center(header), hl.header)
  utils.append(0, empty_line)
  utils.append(0, center(sub_header), hl.header)
  utils.append(0, empty_line)

  -- Set the sections
  dashboard.entries = {}
  set_entries()
  api.nvim_buf_set_lines(0, -2, -1, false, {})

  -- Compute first and last line offset
  -- Actual entry line is 1 greater and 1 less than the current line for setting
  -- the firstline and lastline offset.
  dashboard.firstline = 1 + #header + 1 + #sub_header + 1 + 1
  dashboard.lastline = api.nvim_buf_line_count(0) - 1

  -- Set the footer
  utils.append(0, empty_line)
  utils.append(0, center(generate_footer()), hl.footer)

  -- Lock the buffer
  option_process(
    { modifiable = false, modified = false, filetype = "dashboard" },
    "set"
  )

  api.nvim_buf_set_name(0, "Dashboard")
  set_mappings()

  -- Initially, the newline will be the firstline
  dashboard.newline = dashboard.firstline
  api.nvim_win_set_cursor(0, { dashboard.firstline, 0 })

  -- Fix column position to the first letter of the second word (skipping the icon)
  cmd "normal! ^ w"
  dashboard.fixed_column = api.nvim_win_get_cursor(0)[2]

  dm.autocmd {
    group = "dashboard",
    events = "CursorMoved",
    targets = "<buffer>",
    command = function()
      require("dm.utils").fixed_column_movement(dashboard)
    end,
  }
  dm.autocmd {
    group = "dashboard",
    events = "BufWipeout",
    targets = "dashboard",
    modifiers = "++once",
    command = reset_opts,
  }
  cmd "silent! %foldopen!"
  cmd "normal! zb"
  o.eventignore = ""
end

-- For debugging purposes:
-- lua print(vim.inspect(require('dm.dashboard')._dashboard))
M._dashboard = dashboard

return M
