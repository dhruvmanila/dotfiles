local M = {}

local Text = require "dm.text"
local session = require "session"

local vim = vim
local o = vim.o
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local nnoremap = dm.nnoremap

-- Useful defaults
local line_length = 50
local hidden_cursor = "a:HiddenCursor/lCursor"

-- Dashboard namespace
local dashboard = {}

-- Dashboard buffer/window options
dashboard.opts = {
  bufhidden = "wipe",
  buflisted = false,
  colorcolumn = "",
  cursorcolumn = false,
  cursorline = false,
  foldcolumn = "0",
  list = false,
  modifiable = true,
  number = false,
  readonly = false,
  relativenumber = false,
  signcolumn = "no",
  spell = false,
  swapfile = false,
  wrap = false,
}

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
    description = function()
      -- Save the name of the last session in the dashboard namespace to be
      -- used to load the session.
      dashboard.last_session = session.last()
      return "  Last session (" .. dashboard.last_session .. ")"
    end,
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
    command = "StartupTime",
  },
}

---@return string[]
local function generate_footer()
  local loaded_plugins = #vim.tbl_filter(
    plugin_loaded,
    vim.tbl_keys(packer_plugins)
  )
  return { "", "", "Neovim loaded " .. loaded_plugins .. " plugins", "" }
end

-- Add the key value to the right end of the given line with the appropriate
-- padding as per the `line_length` value.
---@param line string
---@param key string
---@return string
local function add_key(line, key)
  return line .. string.rep(" ", line_length - #line) .. key
end

-- Add paddings on the left side of every line to make it look like its in the
-- center of the current window.
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

-- Render the text on the buffer using the Text object.
local function render_text()
  local text = Text:new()
  text:block(center(generate_header()), "DashboardHeader", true)
  text:block(center(generate_sub_header()), "DashboardHeader", true)
  for _, entry in ipairs(entries) do
    local description = entry.description
    if type(description) == "function" then
      description = description()
    end
    description = add_key(description, entry.key)
    text:block(center { description }, "DashboardEntry", true)
  end
  text:block(center(generate_footer()), "DashboardFooter")
end

-- Close the dashboard buffer and either quit neovim or move back to the
-- original buffer.
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

-- Setup the required mappings which includes:
--   - q: quit the dashboard buffer
--   - `key`: open the entry for the registered entry
local function setup_mappings()
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

-- Functions to hide and show the cursor using the `HiddenCursor` highlight.
-- The highlight is set in `colorscheme.lua` file.
local cursor = {
  hide = function()
    vim.o.guicursor = hidden_cursor
  end,
  show = function()
    vim.o.guicursor = dashboard.guicursor
  end,
}

-- Setup the required autocmds for the dashboard buffer:
--   - Hide the cursor when entering the dashboard buffer
--   - Show the cursor on the commandline or leaving the dashboard buffer
--   - Reset the options when deleting the dashboard buffer
local function setup_autocmds()
  dm.autocmd {
    group = "dashboard",
    events = { "BufEnter", "CmdlineLeave" },
    targets = "<buffer>",
    command = cursor.hide,
  }
  dm.autocmd {
    group = "dashboard",
    events = { "BufLeave", "CmdlineEnter" },
    targets = "<buffer>",
    command = cursor.show,
  }
  dm.autocmd {
    group = "dashboard",
    events = "BufWipeout",
    targets = "<buffer>",
    modifiers = "++once",
    command = function()
      option_process(dashboard.saved_opts, "set")
      dashboard.saved_opts = {}
    end,
  }
end

--- Open the dashboard buffer in the current buffer if it is empty or create
--- a new buffer for the current window.
---@param on_vimenter? boolean
function M.open(on_vimenter)
  if on_vimenter and (o.insertmode or not o.modifiable) then
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
    dashboard.guicursor = vim.o.guicursor
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

  -- Render the text and lock the buffer
  render_text()
  option_process({
    modifiable = false,
    modified = false,
    filetype = "dashboard",
  }, "set")

  setup_mappings()
  setup_autocmds()

  -- Hide the cursor as everything is invoked through a keymap
  cursor.hide()
  o.eventignore = ""
end

-- For debugging purposes
M._dashboard = dashboard

return M
