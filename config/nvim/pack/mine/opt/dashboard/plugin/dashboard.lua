if vim.g.loaded_dashboard then
  return
end
vim.g.loaded_dashboard = true

local fn = vim.fn
local api = vim.api

local Text = require "dm.text"
local session = require "session"

-- Variables {{{1

-- Entry description length.
local DESC_LENGTH = 50

-- `guicursor` option value to hide the cursor using the `HiddenCursor`
-- highlight group. This is defined in our colorscheme.
local HIDDEN_CURSOR = "a:HiddenCursor/lCursor"

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

---@class DashboardEntry
---@field key string keymap to trigger the `command`
---@field description string|fun():string oneline command description
---@field command string|function execute the string/function on `key`

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
    command = 'lua require("dm.plugin.telescope").find_files()',
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

-- Functions {{{1

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
  -- Why `split()` instead of `vim.split()`? {{{
  --
  -- The former trims empty items at the ends while the latter does not.
  -- There is a PR in the works: https://github.com/neovim/neovim/pull/15218
  --
  -- TODO: update this when the above PR merges
  -- }}}
  local v = fn.split(fn.split(api.nvim_exec("version", true), "\n")[1])[2]
  return { v, "", "" }
end

---@return string[]
local function generate_footer()
  if not packer_plugins then
    return {}
  end
  local loaded_plugins = 0
  for _, info in pairs(packer_plugins) do
    if info.loaded then
      loaded_plugins = loaded_plugins + 1
    end
  end
  return { "", "", "Neovim loaded " .. loaded_plugins .. " plugins" }
end

-- Add the 'key' value to the right end of the given line with the appropriate
-- padding as per the `DESC_LENGTH` value.
---@param line string
---@param key string
---@return string
local function add_key(line, key)
  return line .. string.rep(" ", DESC_LENGTH - #line) .. key
end

-- Add paddings on the left side of every line to make it look like its in the
-- center of the current window.
---@param lines string[]
---@return string[]
local function center(lines)
  local max_length = 0
  for _, line in ipairs(lines) do
    max_length = math.max(max_length, api.nvim_strwidth(line))
  end
  local shift = math.floor(api.nvim_win_get_width(0) / 2 - max_length / 2)
  return vim.tbl_map(function(line)
    return string.rep(" ", shift) .. line
  end, lines)
end

---@alias OptionProcess
---|'"set"' # set the options using the `opts` table
---|'"save"' # save the option values for the given `opts` table
---@param opts table<string, any>
---@param process OptionProcess
local function option_process(opts, process)
  assert(process == "save" or process == "set", "Incorrect 'process' value")
  for name, value in pairs(opts) do
    if process == "set" then
      -- FIXME: Currently `opt_local` is broken in Neovim as it leaks
      -- window options to other windows. It seems that `setlocal` is magical
      vim.opt_local[name] = value
    elseif process == "save" then
      dashboard.saved_opts[name] = vim.opt_local[name]:get()
    end
  end
end

-- Render the text on the buffer using the Text object.
local function render_text()
  local text = Text:new()
  --                        add a newline after the block ─┐
  --                                                       │
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

-- Close the dashboard buffer and either quit Neovim or move back to the
-- original buffer.
local function close()
  local listed_bufs = vim.tbl_filter(function(bufnr)
    return fn.buflisted(bufnr) == 1
  end, api.nvim_list_bufs())

  -- NOTE: If we have enabled the `buflisted` option for the dashboard buffer,
  -- then subtract 1 to this to get the correct number.
  if #listed_bufs == 0 then
    vim.cmd "quit"
  else
    local current = api.nvim_get_current_buf()
    local alternate = fn.bufnr "#"
    if api.nvim_buf_is_loaded(alternate) and alternate ~= current then
      api.nvim_set_current_buf(alternate)
    else
      vim.cmd "bnext"
    end
  end
end

local cursor = {
  hide = function()
    vim.o.guicursor = HIDDEN_CURSOR
  end,
  show = function()
    vim.o.guicursor = dashboard.guicursor
  end,
}

-- Setup the required mappings which includes:
--   - q: quit the dashboard buffer
--   - `key`: open the entry for the registered entry
local function setup_mappings()
  local opts = { buffer = true, nowait = true }
  dm.nnoremap("q", close, opts)
  for _, entry in ipairs(entries) do
    local command = entry.command
    if type(command) == "string" then
      command = "<Cmd>" .. command .. "<CR>"
    end
    dm.nnoremap(entry.key, command, opts)
  end
end

-- Setup the required autocmds for the dashboard buffer:
--   - Hide the cursor when entering the dashboard buffer
--   - Show the cursor on the command-line or leaving the dashboard buffer
--   - Reset the options when deleting the dashboard buffer
local function setup_autocmds()
  dm.autocmd {
    events = { "BufEnter", "CmdlineLeave" },
    targets = "<buffer>",
    command = cursor.hide,
  }
  dm.autocmd {
    events = { "BufLeave", "CmdlineEnter" },
    targets = "<buffer>",
    command = cursor.show,
  }
  -- TODO: This should not be needed once the options bug is fixed upstream
  dm.autocmd {
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
local function open(on_vimenter)
  if on_vimenter and (vim.o.insertmode or not vim.bo.modifiable) then
    return
  end

  -- We will ignore all events while creating the dashboard buffer as it might
  -- result in unintended effect when dashboard is called in a nested fashion.
  vim.o.eventignore = "all"

  -- Save the current window/buffer options
  -- If we are being called from a dashboard buffer, then we should not save
  -- the options as it will save the dashboard buffer specific options.
  if vim.bo.filetype ~= "dashboard" then
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
    if vim.bo.filetype == "dashboard" then
      vim.cmd(("keepalt call nvim_win_set_buf(0, %d)"):format(bufnr))
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

  -- Hide the cursor as everything is invoked through keys
  cursor.hide()
  vim.o.eventignore = ""
end

-- Setup {{{1

dm.augroup("dm__dashboard", {
  {
    events = "VimEnter",
    targets = "*",
    command = function()
      if fn.argc() == 0 and fn.line2byte "$" == -1 then
        open(true)
      end
    end,
  },
  {
    events = "VimResized",
    targets = "*",
    command = function()
      if vim.bo.filetype == "dashboard" then
        open()
      end
    end,
  },
})

dm.command("Dashboard", open, { bar = true })

dm.nnoremap("<leader>`", "<Cmd>Dashboard<CR>")
