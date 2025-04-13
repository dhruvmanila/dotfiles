local icons = dm.icons

local provider = require 'dm.provider'
local utils = require 'dm.utils'

-- Pad the given component with a space on both sides, if it's given.
---@param component string
---@return string
local function pad(component)
  if component ~= nil and component ~= '' then
    return ' ' .. component .. ' '
  end
  return ''
end

-- Return the buffer information which includes indent style, indent size,
-- fileencoding and fileformat.
---@return string
local function buffer_info()
  local encoding = vim.bo.fileencoding
  if encoding == '' then
    encoding = vim.o.encoding
  end
  return (' %s:%d  %s %s '):format(
    vim.bo.expandtab and 'S' or 'T',
    vim.bo.shiftwidth,
    encoding:upper(),
    vim.bo.fileformat == 'unix' and 'LF' or 'CRLF'
  )
end

-- Return information regarding the current git repository which includes the
-- branch name and diff count.
---@see g:gitsigns_head b:gitsigns_head b:gitsigns_status
---@return string
local function git_info()
  local info = ''
  local head = vim.b.gitsigns_head
  if head and head ~= '' then
    info = '󰘬 ' .. head
  end
  local status = vim.b.gitsigns_status
  if status and status ~= '' then
    info = info .. ' ' .. status
  end
  local conflict_count = require('git-conflict').conflict_count()
  if conflict_count > 0 then
    info = info .. ' !' .. conflict_count
  end
  return info
end

-- Return the Python version and virtual environment name if we are in any.
---@return string
local function python_version()
  local version = vim.g.current_python_version
  local env = vim.g.current_python_venv_name
  env = env and ' (' .. env .. ')' or ''
  return (version or '') .. env
end

-- Return the filetype related information.
---@return string
local function filetype()
  local ft = vim.bo.filetype
  if ft == 'python' then
    return python_version()
  end
  return ft
end

-- Function to run the LspInfo command when clicking on the icon/message
-- on the statusline.
function _G.st_open_lsp_info()
  vim.cmd.LspInfo()
end

-- Return an icon if there are active LSP client(s). If the region containing
-- the icon is clicked, then the `LspInfo` command is ran.
---@return string
local function lsp_icon()
  local result = ''
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if not vim.tbl_isempty(clients) then
    result = '%@v:lua.st_open_lsp_info@' .. '%T'
  end
  return result
end

-- Used for showing the LSP diagnostics information. The order is maintained.
local DIAGNOSTIC_OPTS = {
  { severity = vim.diagnostic.severity.INFO, icon = icons.info, hl = '%6*' },
  { severity = vim.diagnostic.severity.HINT, icon = icons.hint, hl = '%7*' },
  { severity = vim.diagnostic.severity.WARN, icon = icons.warn, hl = '%8*' },
  { severity = vim.diagnostic.severity.ERROR, icon = icons.error, hl = '%9*' },
}

-- Return the diagnostics information if > 0.
---@return string
local function lsp_diagnostics()
  local result = {}
  for _, opt in ipairs(DIAGNOSTIC_OPTS) do
    local count = vim.tbl_count(vim.diagnostic.get(0, { severity = opt.severity }))
    if count > 0 then
      table.insert(result, opt.hl .. opt.icon .. ' ' .. count)
    end
  end
  return table.concat(result, ' %*')
end

-- Return the current status of the DAP client.
---@return string
local function dap_status()
  if not package.loaded.dap then
    return ''
  end
  local status = require('dap').status()
  if status and status ~= '' then
    return ' ' .. status
  end
  return ''
end

-- Provide the global statusline.
---@return string
function _G.nvim_statusline()
  return '%1* '
    .. provider.buffer_name(nil, ':~:.')
    .. provider.buffer_flags()
    .. ' %2*'
    .. pad(git_info())
    .. '%*'
    .. '%<'
    .. pad(vim.w.quickfix_title)
    .. pad(vim.b.term_title)
    .. pad(lsp_diagnostics())
    .. '%*'
    .. '%='
    .. pad(dap_status())
    .. pad(lsp_icon())
    .. '%2*'
    .. pad(filetype())
    .. '%1*'
    .. ' %2l/%L:%-2c '
    .. buffer_info()
end

local function set_python_version()
  vim.system({ 'python', '--version' }, nil, function(result)
    vim.g.current_python_version = result.stdout:gsub('\r\n', ''):gsub('\n', '')
  end)
end

-- Set the current Python virtual environment name if we are in one.
local function set_python_venv_name()
  local dir = os.getenv 'VIRTUAL_ENV'
  if dir then
    for line in io.lines(dir .. '/pyvenv.cfg') do
      local match = line:match "^prompt = '(.*)'$"
      if match then
        vim.g.current_python_venv_name = match
      end
    end
    -- Fallback to the directory name.
    if not vim.g.current_python_venv_name then
      vim.g.current_python_venv_name = vim.fs.basename(dir)
    end
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dm__statusline', { clear = true }),
  pattern = 'python',
  callback = function()
    if dm.is_executable 'python' then
      utils.set_interval_callback(5 * 1000, set_python_version)
      utils.set_interval_callback(5 * 1000, set_python_venv_name)
    end
  end,
})

-- :h qf.vim, disable quickfix statusline
vim.g.qf_disable_statusline = 1

if dm.KITTY_SCROLLBACK then
  vim.opt.statusline = '%1* ' .. dm.CWD .. ' %*' .. '%=' .. '%1* %2l/%L:%-2c '
else
  vim.opt.statusline = '%!v:lua.nvim_statusline()'
end
