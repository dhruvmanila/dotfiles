local fn = vim.fn
local api = vim.api

local Text = require 'dm.text'
local session = require 'dm.session'

-- Variables {{{1

-- Entry description length.
local DESC_LENGTH = 50

-- `guicursor` option value to hide the cursor using the `HiddenCursor`
-- highlight group. This is defined in our colorscheme.
local HIDDEN_CURSOR = 'a:HiddenCursor/lCursor'

-- Dashboard namespace
local dashboard = {}

---@class DashboardEntry
---@field key string keymap to trigger the `command`
---@field description string|fun():string oneline command description
---@field command string|function execute the string/function on `key`

---@type DashboardEntry[]
local entries = {}

do
  local last_session = session.last()

  -- Add the entry only if there is any last session.
  if last_session then
    table.insert(entries, {
      key = 'l',
      description = '  Last session (' .. last_session .. ')',
      command = function()
        session.load(last_session)
      end,
    })
  end
end

vim.list_extend(entries, {
  {
    key = 's',
    description = '  Find sessions',
    command = function()
      require('telescope').extensions.custom.sessions(
        require('dm.plugins.telescope.themes').dropdown_list
      )
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
    description = '  Show detailed profiling',
    command = 'Lazy profile',
  },
})

-- Functions {{{1

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
  local version = api.nvim_exec2('version', { output = true }).output
  version = vim.split(
    vim.split(version, '\n', { trimempty = true })[1],
    ' ',
    { trimempty = true }
  )[2]
  return { version, '', '' }
end

---@return string[]
local function generate_footer()
  local stats = require('lazy').stats()
  return {
    '',
    '',
    ('Neovim loaded %d/%d plugins in %dms'):format(
      stats.loaded,
      stats.count,
      stats.startuptime
    ),
  }
end

-- Add the 'key' value to the right end of the given line with the appropriate
-- padding as per the `DESC_LENGTH` value.
---@param line string
---@param key string
---@return string
local function add_key(line, key)
  return line .. string.rep(' ', DESC_LENGTH - #line) .. key
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
  vim.keymap.set('n', 'q', close, opts)
  for _, entry in ipairs(entries) do
    local command = entry.command
    if type(command) == 'string' then
      command = '<Cmd>' .. command .. '<CR>'
    end
    vim.keymap.set('n', entry.key, command, opts)
  end
end

-- Setup the required autocmds for the dashboard buffer:
--   - Hide the cursor when entering the dashboard buffer
--   - Show the cursor on the command-line or leaving the dashboard buffer
--   - Reset the options when deleting the dashboard buffer
local function setup_autocmds()
  api.nvim_create_autocmd({ 'BufEnter', 'CmdlineLeave' }, {
    pattern = '<buffer>',
    callback = cursor.hide,
  })
  api.nvim_create_autocmd({ 'BufLeave', 'CmdlineEnter' }, {
    pattern = '<buffer>',
    callback = cursor.show,
  })
end

--- Open the dashboard buffer in the current buffer if it is empty or create
--- a new buffer for the current window.
---@param on_vimenter boolean
local function open(on_vimenter)
  vim.validate { on_vimenter = { on_vimenter, 'boolean', true } }
  if on_vimenter and (vim.o.insertmode or not vim.bo.modifiable) then
    return
  end

  -- We will ignore all events while creating the dashboard buffer as it might
  -- result in unintended effect when dashboard is called in a nested fashion.
  vim.o.eventignore = 'all'

  -- Save the current window/buffer options
  -- If we are being called from a dashboard buffer, then we should not save
  -- the options as it will save the dashboard buffer specific options.
  if vim.bo.filetype ~= 'dashboard' then
    dashboard.guicursor = vim.o.guicursor
  end

  -- Create a new, unnamed buffer
  if fn.line2byte '$' ~= -1 then
    local bufnr = api.nvim_create_buf(true, true)
    -- If we are being called from a dashboard buffer in a nested fashion, we
    -- should keep the alternate buffer which is the one we go to when we
    -- quit the dashboard buffer.
    if vim.bo.filetype == 'dashboard' then
      vim.cmd(('keepalt call nvim_win_set_buf(0, %d)'):format(bufnr))
    else
      api.nvim_win_set_buf(0, bufnr)
    end
  end

  -- Set this flag for other plugins to check if the dashboard was opened
  -- on vimenter.
  vim.b.dashboard_on_vimenter = on_vimenter

  -- Set the dashboard buffer options
  api.nvim_set_option_value('bufhidden', 'wipe', { scope = 'local' })
  api.nvim_set_option_value('buflisted', false, { scope = 'local' })
  api.nvim_set_option_value('colorcolumn', '', { scope = 'local' })
  api.nvim_set_option_value('cursorcolumn', false, { scope = 'local' })
  api.nvim_set_option_value('cursorline', false, { scope = 'local' })
  api.nvim_set_option_value('foldcolumn', '0', { scope = 'local' })
  api.nvim_set_option_value('list', false, { scope = 'local' })
  api.nvim_set_option_value('modifiable', true, { scope = 'local' })
  api.nvim_set_option_value('number', false, { scope = 'local' })
  api.nvim_set_option_value('readonly', false, { scope = 'local' })
  api.nvim_set_option_value('relativenumber', false, { scope = 'local' })
  api.nvim_set_option_value('signcolumn', 'no', { scope = 'local' })
  api.nvim_set_option_value('spell', false, { scope = 'local' })
  api.nvim_set_option_value('swapfile', false, { scope = 'local' })
  api.nvim_set_option_value('wrap', false, { scope = 'local' })

  -- Render the text and lock the buffer
  render_text()
  api.nvim_set_option_value('modifiable', false, { scope = 'local' })
  api.nvim_set_option_value('modified', false, { scope = 'local' })
  api.nvim_set_option_value('filetype', 'dashboard', { scope = 'local' })

  api.nvim_buf_set_name(0, '[Dashboard]')
  setup_mappings()
  setup_autocmds()

  -- Hide the cursor as everything is invoked through keys
  cursor.hide()
  vim.o.eventignore = ''
end

-- }}}1

return { open = open }
