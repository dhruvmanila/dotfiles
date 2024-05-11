local fn = vim.fn
local api = vim.api

local Text = require 'dm.text'
local utils = require 'dm.utils'

-- Entry description length.
local DESC_LENGTH = 50

---@type DashboardEntry[]
local entries = {}

vim.list_extend(entries, {
  {
    key = 'l',
    description = '  Load current session',
    command = function()
      require('dm.session').load()
    end,
  },
  {
    key = 's',
    description = '  Find sessions',
    command = function()
      require('dm.session').select()
    end,
  },
  {
    key = 'e',
    description = '  New file',
    command = 'enew',
  },
  {
    key = 'h',
    description = '  Recently opened files',
    command = function()
      require('telescope.builtin').oldfiles()
    end,
  },
  {
    key = 'f',
    description = '  Find files',
    command = function()
      require('dm.plugins.telescope.pickers').find_files()
    end,
  },
  {
    key = 'u',
    description = '  Sync packages',
    command = 'Lazy sync',
  },
  {
    key = 'p',
    description = '󰔛  Show detailed profiling',
    command = 'Lazy profile',
  },
})

---@return string[]
local function generate_header()
  return {
    '',
    '',
    '',
    '███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    '████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    '██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    '██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    '██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    '╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
  }
end

---@return string[]
local function generate_sub_header()
  return { tostring(vim.version()), '', '' }
end

---@return string[]
local function generate_footer()
  local stats = require('lazy').stats()
  return {
    '',
    '',
    ('Neovim loaded %d/%d plugins in %dms'):format(stats.loaded, stats.count, stats.startuptime),
  }
end

-- Add the 'key' value to the right end of the given line with the appropriate
-- padding as per the `DESC_LENGTH` value.
---@param line string
---@param key string
---@return string
local function add_key(line, key)
  return line .. string.rep(' ', DESC_LENGTH - api.nvim_strwidth(line)) .. key
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
    return string.rep(' ', shift) .. line
  end, lines)
end

-- Render the text on the buffer using the Text object.
local function render_text()
  local text = Text:new()
  --                        add a newline after the block ─┐
  --                                                       │
  text:block(center(generate_header()), 'DashboardHeader', true)
  text:block(center(generate_sub_header()), 'DashboardHeader', true)
  for _, entry in ipairs(entries) do
    local description = entry.description
    if type(description) == 'function' then
      description = description()
    end
    description = add_key(description, entry.key)
    text:block(center { description }, 'DashboardEntry', true)
  end
  text:block(center(generate_footer()), 'DashboardFooter')
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
    vim.cmd 'quit'
  else
    local current = api.nvim_get_current_buf()
    local alternate = fn.bufnr '#'
    if api.nvim_buf_is_loaded(alternate) and alternate ~= current then
      api.nvim_set_current_buf(alternate)
    else
      vim.cmd 'bnext'
    end
  end
end

-- Setup the required mappings which includes:
--   - q: quit the dashboard buffer
--   - `key`: open the entry for the registered entry
local function setup_mappings()
  local opts = { buffer = true, nowait = true }
  vim.keymap.set('n', 'q', close, opts)
  for _, entry in ipairs(entries) do
    local command = entry.command
    if type(command) == 'string' then
      command = '<Cmd>' .. command .. '<CR>'
    end
    vim.keymap.set('n', entry.key, command, opts)
  end
end

--- Open the dashboard buffer in the current buffer if it is empty or create
--- a new buffer for the current window.
local function open()
  if api.nvim_get_mode().mode == 'i' or not vim.bo.modifiable then
    return
  end

  -- Create a new, unnamed buffer
  if not utils.buf_is_empty() then
    local bufnr = api.nvim_create_buf(false, true)
    -- If we are being called from a dashboard buffer in a nested fashion, we
    -- should keep the alternate buffer which is the one we go to when we
    -- quit the dashboard buffer.
    if vim.bo.filetype == 'dashboard' then
      vim.cmd(('keepalt call nvim_win_set_buf(0, %d)'):format(bufnr))
    else
      api.nvim_win_set_buf(0, bufnr)
    end
  end

  -- Set the dashboard buffer options
  vim.opt_local.bufhidden = 'wipe'
  vim.opt_local.buflisted = false
  vim.opt_local.colorcolumn = ''
  vim.opt_local.cursorcolumn = false
  vim.opt_local.cursorline = false
  vim.opt_local.foldcolumn = '0'
  vim.opt_local.list = false
  vim.opt_local.modifiable = true
  vim.opt_local.number = false
  vim.opt_local.readonly = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.spell = false
  vim.opt_local.statuscolumn = ''
  vim.opt_local.swapfile = false
  vim.opt_local.winbar = ''
  vim.opt_local.wrap = false

  -- Render the text and lock the buffer
  render_text()
  vim.opt_local.modifiable = false
  vim.opt_local.modified = false
  vim.opt_local.filetype = 'dashboard'

  api.nvim_buf_set_name(0, '[Dashboard]')
  setup_mappings()
end

-- }}}1

return { open = open }
