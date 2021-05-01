local icons = require('core.icons').icons
local warn = require('core.utils').warm

local M = {}
local saved_options = {}

-- TODO: instead of hardcoding the value, compute it with max entry length
-- + some value like 10 or 20
local line_length = 30
local session_dir = vim.fn.stdpath('data') .. '/session'

--- Add the key value to the right end of the given line with the appropriate
--- padding as per the `line_length` value.
---@param line string
---@param key string
---@return string
local function add_key(line, key)
  return line .. string.rep(" ", line_length - #line) .. key
end

--- Last session entry description.
local function last_session_description()
  local path = vim.fn.resolve(session_dir .. '/__LAST__')
  local name = vim.fn.fnamemodify(path, ':t')
  return icons.pin .. '  Last session (' .. name ..')'
end

local entries = {
  {
    key = 'l',
    description = last_session_description,
    command = "lua require('core.session').load_session('__LAST__')",
  },
  {
    key = 's',
    description = icons.globe .. '  Find sessions',
    command = "lua require('plugin.telescope').sessions()",
  },
}

--- Generate and return the header of the start page.
---@return table
local function header()
  return {
    '',
    '',
    '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
    '',
    '',
  }
end

--- Generate and return the footer of the start page.
---@return table
local function footer()
  local loaded_plugins = #vim.tbl_filter(function(plugin)
    return plugin.loaded
  end, _G.packer_plugins)

  return {
    '',
    'neovim loaded ' .. loaded_plugins .. ' plugins',
    '',
  }
end

--- Add paddings on the left side of every line to make it look like its in the
--- center of the current window.
---@param lines table
---@return table
local function center(lines)
  local longest_line = math.max(unpack(vim.tbl_map(function(line)
    return vim.fn.strwidth(line)
  end, lines)))
  local shift = math.floor(vim.api.nvim_win_get_width(0) / 2 - longest_line / 2)
  return vim.tbl_map(function(line) return string.rep(" ", shift) .. line end, lines)
end

--- Perform either of the three process for the current buffer:
---   - set the given options
---   - save the option values for the given `opts`
---   - restore from the saved options
---@param opts table
---@param process string - set|save|restore
local function option_process(opts, process)
  if process == "set" then
    for name, value in pairs(opts) do
      vim.api.nvim_buf_set_option(0, name, value)
    end
  elseif process == "save" then
    for name, _ in pairs(opts) do
      saved_options[name] = vim.api.nvim_buf_get_option(0, name)
    end
  elseif process == "restore" then
    for name, value in pairs(saved_options) do
      vim.api.nvim_buf_set_option(0, name, value)
    end
    saved_options = {}
  else
    error("Unknown 'process' value: " .. process)
  end
end

--- Set or reset the buffer options
---@param opts table
---@param reset boolean
local function set_options(opts, reset)
  for name, value in pairs(opts) do
    if not reset then
      saved_options[name] = vim.api.nvim_buf_get_option(0, name)
    end
  end
end

---@param section function|table
---@return table
local function set_section(section)
  return type(section) == 'function' and section() or section
end

function M.start(on_vimenter)
  if on_vimenter and (vim.o.insertmode or not vim.o.modifiable) then
    return
  end

  if not vim.o.hidden and vim.o.modified then
    warn("[start] Please save your changes first.")
    return
  end

  local opts = {
    bufhidden = 'wipe',
    colorcolumn = '',
    foldcolumn = 0,
    matchpairs = '',
    modifiable = true,
    buflisted = false,
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

  -- option_process(opts, 'save')

  if vim.fn.line2byte('$') ~= -1 then
    vim.api.nvim_command("noautocmd enew")
  end

  -- option_process(opts, 'set')
end

M.start(false)

return M
