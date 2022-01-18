local fn = vim.fn
local api = vim.api
local icons = dm.icons
local job = require "dm.job"

local function center(str)
  return "%=" .. str .. "%="
end

-- Custom statusline for special builtin/plugin buffers.
---@type table<string, string|function>
local special_buffer_line = {
  dashboard = function(ctx)
    return center(" %<" .. fn.fnamemodify(ctx.bufname, ":~"))
  end,

  fugitive = center " Fugitive",

  gitcommit = center " Commit message",

  help = function(ctx)
    return ctx.inactive and center "%t" or "%1* %l/%L %*%2* help %* %t"
  end,

  lir = function(ctx)
    return center(" %<" .. fn.fnamemodify(ctx.bufname, ":~"))
  end,

  man = function(ctx)
    return ctx.inactive and center "%t" or "%1* %l/%L %*%2* Man %* %t"
  end,

  packer = center " Packer",

  qf = function(ctx)
    local typ = fn.win_gettype(ctx.winnr)
    typ = typ == "loclist" and "Location" or "Quickfix"
    local ok, title = pcall(api.nvim_win_get_var, ctx.winnr, "quickfix_title")
    title = ok and title or ""
    if ctx.inactive then
      return "%1* %l/%L %* " .. typ .. " List  " .. title
    end
    return "%1* %l/%L %*%2* " .. typ .. " List %* " .. title
  end,

  startuptime = center " Startup time",

  terminal = center " %{b:term_title}",

  tsplayground = center "侮Syntax Tree Playground",
}

-- Return the buffer information such as fileencoding, fileformat, indentation.
---@param ctx table
---@return string
local function buffer_info(ctx)
  local bo = vim.bo[ctx.bufnr]
  local encoding = bo.fileencoding ~= "" and bo.fileencoding or vim.o.encoding
  local fileinfo = ("%s%s")
    :format(
      encoding ~= "utf-8" and encoding .. " " or "",
      bo.fileformat ~= "unix" and bo.fileformat .. " " or ""
    )
    :upper()
  local indent = (bo.expandtab and "S:" or "T:") .. bo.shiftwidth
  return " " .. indent .. (fileinfo ~= "" and " | " .. fileinfo or "") .. " "
end

---@see b:gitsigns_head g:gitsigns_head
---@return string
local function git_branch()
  local head = vim.b.gitsigns_head
  if head and head ~= "" then
    return "  " .. head .. " "
  end
  return ""
end

-- Return the Python version and virtual environment name if we are in any.
---@return string
local function python_version()
  local env = vim.g.current_python_venv_name
  local version = vim.g.current_python_version
  env = env and "(" .. env .. ") " or ""
  version = version and " " .. version .. " " or ""
  return version .. env
end

---@param ctx table
---@return string
local function filetype(ctx)
  local ft = ctx.filetype
  if ft == "" then
    return ""
  elseif ft == "python" then
    return python_version()
  end
  return " " .. ft .. " "
end

-- Return the currently active neovim LSP client(s) and the status message.
---@param ctx table
---@return string
local function lsp_clients_and_messages(ctx)
  local result = {}
  local clients = vim.lsp.buf_get_clients(ctx.bufnr)
  for id, client in pairs(clients) do
    table.insert(result, client.name .. ":" .. id)
  end
  if not vim.tbl_isempty(result) then
    result = "  " .. table.concat(result, " ") .. " "
    local message = vim.g.lsp_progress_message
    if message and message ~= "" then
      result = result .. "| " .. message .. " "
    end
    return result
  end
  return ""
end

-- Used for showing the LSP diagnostics information. The order is maintained.
local DIAGNOSTIC_OPTS = {
  { severity = vim.diagnostic.severity.INFO, icon = icons.info, hl = "%6*" },
  { severity = vim.diagnostic.severity.HINT, icon = icons.hint, hl = "%7*" },
  { severity = vim.diagnostic.severity.WARN, icon = icons.warn, hl = "%8*" },
  {
    severity = vim.diagnostic.severity.ERROR,
    icon = icons.error,
    hl = "%9*",
  },
}

-- Return the diagnostics information if > 0.
---@param ctx table
---@return string
local function lsp_diagnostics(ctx)
  local bufnr = ctx.bufnr
  local result = {}
  for _, opt in ipairs(DIAGNOSTIC_OPTS) do
    local count = vim.tbl_count(
      vim.diagnostic.get(bufnr, { severity = opt.severity })
    )
    if count > 0 then
      table.insert(result, opt.hl .. opt.icon .. " " .. count)
    end
  end
  result = table.concat(result, " %*")
  return result ~= "" and " " .. result or ""
end

-- Return the current status of the DAP client.
---@return string
local function dap_status()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return ""
  end
  local status = dap.status()
  if status and status ~= "" then
    return " " .. status .. " |"
  end
  return ""
end

---@param ctx table
---@return string
local function special_buffer_statusline(ctx)
  local typ = ctx.filetype ~= "" and ctx.filetype or ctx.buftype
  local line = special_buffer_line[typ]
  if not line then
    return
  elseif type(line) == "function" then
    return line(ctx)
  else
    return line
  end
end

-- Provide the statusline for different types of buffers including active,
-- inactive, special buffers such as Dashboard, Terminal, quickfix, etc.
---@return string
function _G.nvim_statusline()
  local winnr = vim.g.statusline_winid or 0
  local bufnr = api.nvim_win_get_buf(winnr)
  local inactive = api.nvim_get_current_win() ~= winnr

  local ctx = {
    winnr = winnr,
    bufnr = bufnr,
    bufname = fn.bufname(bufnr),
    filetype = vim.bo[bufnr].filetype,
    buftype = vim.bo[bufnr].buftype,
    inactive = inactive,
  }

  local line = special_buffer_statusline(ctx)
  if line and line ~= "" then
    return line
  elseif inactive then
    return center(fn.fnamemodify(ctx.bufname, ":~:."))
  end

  -- The initial space is to compensate for the signcolumn.
  return "%1*  "
    .. "%L:%-2c " -- total:column
    .. "%*"
    .. "%2*"
    .. git_branch()
    .. "%*"
    .. "%<"
    .. lsp_diagnostics(ctx)
    .. "%*"
    .. "%="
    .. dap_status()
    .. lsp_clients_and_messages(ctx)
    .. "%2*"
    .. filetype(ctx)
    .. "%*"
    .. "%1*"
    .. buffer_info(ctx)
    .. "%*"
end

-- Create a timer for the given callback to be invoked every `interval` ms.
---@param interval number (ms)
---@param callback function
---@return number #timer handle (uv_timer_t)
local function set_interval_callback(interval, callback)
  vim.defer_fn(callback, 100)
  local timer = vim.loop.new_timer()
  timer:start(interval, interval, function()
    callback()
  end)
  return timer
end

local function set_python_version()
  job {
    cmd = "python",
    args = { "--version" },
    ---@param result JobResult
    on_exit = function(result)
      vim.g.current_python_version = result.stdout:gsub("\n", "")
    end,
  }
end

-- Set the current Python virtual environment name if we are in one.
local function set_python_venv_name()
  local dir = os.getenv "VIRTUAL_ENV"
  if dir then
    for line in io.lines(dir .. "/pyvenv.cfg") do
      local match = line:match "^prompt = '(.*)'$"
      if match then
        vim.g.current_python_venv_name = match
      end
    end
    -- Fallback to the directory name.
    if not vim.g.current_python_venv_name then
      vim.g.current_python_venv_name = fn.fnamemodify(dir, ":t")
    end
  end
end

dm.augroup("dm__statusline", {
  {
    events = "FileType",
    targets = "python",
    command = function()
      if fn.executable "python" > 0 then
        set_interval_callback(5 * 1000, set_python_version)
      end
      set_interval_callback(5 * 1000, set_python_venv_name)
    end,
  },
})

-- :h qf.vim, disable quickfix statusline
vim.g.qf_disable_statusline = 1

vim.o.statusline = "%!v:lua.nvim_statusline()"
