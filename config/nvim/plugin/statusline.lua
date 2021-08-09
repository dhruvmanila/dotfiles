local fn = vim.fn
local api = vim.api
local icons = dm.icons
local utils = require "dm.utils"

local colors = {
  active_bg = "#3a3735",
  inactive_bg = "#32302f",
  active_fg = "#a89984",
  inactive_fg = "#7c6f64",
  yellow = "#e9b143",
  red = "#f2594b",
  aqua = "#8bba7f",
  blue = "#80aa9e",
}

local highlights = {
  StatusLine = { guifg = colors.active_fg, guibg = colors.active_bg },
  StatusLineNC = { guifg = colors.inactive_fg, guibg = colors.inactive_bg },

  -- Basic User highlight group
  User1 = { guifg = "#282828", guibg = "#7d6f64", gui = "bold" },
  User2 = { guifg = "#ebdbb2", guibg = "#504945" },

  -- LSP diagnostics group
  User6 = { guifg = colors.blue, guibg = colors.active_bg },
  User7 = { guifg = colors.aqua, guibg = colors.active_bg },
  User8 = { guifg = colors.yellow, guibg = colors.active_bg },
  User9 = { guifg = colors.red, guibg = colors.active_bg },
}

local function center(str)
  return "%=" .. str .. "%="
end

-- Custom statusline for special builtin/plugin buffers.
---@type table<string, string|function>
local special_buffer_line = {
  terminal = center " Terminal:%t",
  tsplayground = center "侮Syntax Tree Playground",
  packer = center " Packer",
  gitcommit = center " Commit message",
  fugitive = center " Fugitive",

  help = function(ctx)
    return ctx.inactive and center "%t" or "%1* %l/%L %*%2* help %* %t"
  end,

  man = function(ctx)
    return ctx.inactive and center "%t" or "%1* %l/%L %*%2* Man %* %t"
  end,

  lir = function(ctx)
    return center(" %<" .. fn.fnamemodify(ctx.bufname, ":~"))
  end,

  dashboard = function(ctx)
    return center(" %<" .. fn.fnamemodify(ctx.bufname, ":~"))
  end,

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
}

-- Return the buffer information such as fileencoding, fileformat, indentation.
---@param ctx table
---@return string
local function buffer_info(ctx)
  local bo = vim.bo[ctx.bufnr]
  local enc = bo.fileencoding
  enc = enc ~= "" and enc or vim.o.encoding
  local format = bo.fileformat:upper()
  local indent = (bo.expandtab and "S:" or "T:") .. bo.shiftwidth
  return " " .. indent .. " | " .. enc:upper() .. " " .. format .. " "
end

-- Return the Git branch name (requires fugitive.vim)
---@return string
local function git_branch()
  local FugitiveHead = vim.fn["FugitiveHead"]
  if FugitiveHead then
    local head = FugitiveHead()
    if head and head ~= "" then
      return "  " .. head .. " "
    end
  end
  return ""
end

-- Return the Python version and virtual environment name if we are in any.
---@param ctx table
---@return string
local function python_version(ctx)
  local env = os.getenv "VIRTUAL_ENV"
  local version = vim.g.current_python_version
  env = env and "(" .. fn.fnamemodify(env, ":t") .. ") " or ""
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
    return python_version(ctx)
  end
  return " " .. ft .. " "
end

-- Return the currently active neovim LSP client(s) if any.
---@param ctx table
---@return string
local function lsp_clients(ctx)
  local result = {}
  local clients = vim.lsp.buf_get_clients(ctx.bufnr)
  for id, client in pairs(clients) do
    table.insert(result, client.name .. ":" .. id)
  end
  result = table.concat(result, " ")
  return result ~= "" and "  " .. result .. " " or ""
end

-- Used for showing the LSP diagnostics information. The order is maintained.
local diagnostics_opts = {
  { severity = "Information", icon = icons.info, hl = "%6*" },
  { severity = "Hint", icon = icons.hint, hl = "%7*" },
  { severity = "Warning", icon = icons.warning, hl = "%8*" },
  { severity = "Error", icon = icons.error, hl = "%9*" },
}

-- Return the diagnostics information if > 0.
---@param ctx table
---@return string
local function lsp_diagnostics(ctx)
  local bufnr = ctx.bufnr
  local result = {}
  for _, opt in ipairs(diagnostics_opts) do
    local count = vim.lsp.diagnostic.get_count(bufnr, opt.severity)
    if count > 0 then
      table.insert(result, opt.hl .. opt.icon .. " " .. count)
    end
  end
  result = table.concat(result, " %*")
  return result ~= "" and " " .. result or ""
end

-- Return the Neovim LSP status message if any.
---@return string
local function lsp_messages()
  local message = vim.g.lsp_progress_message
  if message and message ~= "" then
    return "| " .. message .. " "
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
    .. lsp_clients(ctx)
    .. lsp_messages()
    .. "%2*"
    .. filetype(ctx)
    .. "%*"
    .. "%1*"
    .. buffer_info(ctx)
    .. "%*"
end

-- Create a timer for the given task to be invoked every `interval` ms.
---@param interval number (ms)
---@param task function
local function job(interval, task)
  vim.defer_fn(task, 100)
  local pending_job
  fn.timer_start(interval, function()
    if pending_job then
      fn.jobstop(pending_job)
    end
    pending_job = task()
  end, {
    ["repeat"] = -1,
  })
end

local function set_python_version()
  return fn.jobstart("python --version", {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and data[1] ~= "" then
        vim.g.current_python_version = data[1]
      end
    end,
  })
end

dm.augroup("dm__statusline", {
  {
    events = { "VimEnter", "ColorScheme" },
    targets = "*",
    command = function()
      for hl_name, opts in pairs(highlights) do
        utils.highlight(hl_name, opts)
      end
    end,
  },
  {
    events = "FileType",
    targets = "python",
    command = function()
      if fn.executable "python" > 0 then
        job(5 * 1000, set_python_version)
      end
    end,
  },
})

-- :h qf.vim, disable quickfix statusline
vim.g.qf_disable_statusline = 1

vim.o.statusline = "%!v:lua.nvim_statusline()"
