local utils = require "dm.utils"
local session = require "dm.session"
local Text = require "dm.text"

-- Extract out the required namespace/function
local vim = vim
local o = vim.o
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local nnoremap = dm.nnoremap

local M = {}

-- Useful defaults
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
--- This will save the name of the last session in the dashboard namespace to
--- be used to load the session.
---@return string[]
local function last_session_description()
  local fs_stat = vim.loop.fs_stat
  local session_dir = vim.g.session_dir
  local sessions = session.list()
  table.sort(sessions, function(a, b)
    a = session_dir .. "/" .. a
    b = session_dir .. "/" .. b
    return fs_stat(a).mtime.sec > fs_stat(b).mtime.sec
  end)
  dashboard.last_session = sessions[1]
  return "  Last session (" .. sessions[1] .. ")"
end

--- Generate and return the header of the start page.
---@return string[]
local function generate_header()
  return {
    "",
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
    command = function()
      session.load(dashboard.last_session)
    end,
  },
  {
    key = "s",
    description = "  Find sessions",
    command = 'lua require("dm.plugin.telescope").sessions()',
  },
  {
    key = "e",
    description = "  New file",
    command = "enew",
  },
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

--- Set the entries in the buffer.
local function set_entries(text)
  for _, entry in ipairs(entries) do
    local description = entry.description
    if type(description) == "function" then
      description = description()
    end
    description = add_key(description, entry.key)
    text:block(center { description }, hl.entry, true)
  end
end

--- Close the dashboard buffer and either quit neovim or move back to the
--- original buffer.
local function close()
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

--- Set the required mappings which includes:
---   - q: quit the dashboard buffer
---   - `key`: open the entry for the registered entry
local function set_mappings()
  local opts = { buffer = true, nowait = true }
  nnoremap("q", close, opts)
  for _, entry in ipairs(entries) do
    local command = entry.command
    if type(command) == "string" then
      command = "<Cmd>" .. command .. "<CR>"
    end
    nnoremap(entry.key, command, opts)
  end
end

--- Open the dashboard buffer in the current buffer if it is empty or create
--- a new buffer for the current window.
---@param on_vimenter? boolean
function M.open(on_vimenter)
  if on_vimenter and (o.insertmode or not o.modifiable) then
    return
  end

  if not o.hidden and o.modified then
    vim.notify("[dashboard]: Please save your changes first", 3)
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

  -- Initiate the Text object which will render the text on the buffer.
  local text = Text:new()

  -- Set the header
  local header = generate_header()
  local sub_header = generate_sub_header()
  text:block(center(header), hl.header, true)
  text:block(center(sub_header), hl.header, true)

  -- Set the sections
  set_entries(text)

  -- Compute first and last line offset
  -- Actual entry line is 1 greater and 1 less than the current line for setting
  -- the firstline and lastline offset.
  dashboard.firstline = #header + 1 + #sub_header + 1 + 1
  dashboard.lastline = api.nvim_buf_line_count(0) - 1

  -- Set the footer
  text:block(center(generate_footer()), hl.footer)

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
    command = function()
      option_process(dashboard.saved_opts, "set")
      dashboard.saved_opts = {}
    end,
  }
  cmd "silent! %foldopen!"
  cmd "normal! zb"
  o.eventignore = ""
end

-- For debugging purposes
M._dashboard = dashboard

return M
