-- Ref:
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/statusline
local fn = vim.fn
local api = vim.api
local contains = vim.tbl_contains
local devicons = require "nvim-web-devicons"
local icons = require "dm.icons"
local utils = require "dm.utils"

-- Colors are taken from the current colorscheme
-- TODO: Any way of taking the values directly from the common highligh groups?
local colors = {
  active_bg = "#3a3735",
  inactive_bg = "#32302f",
  active_fg = "#e2cca9",
  inactive_fg = "#7c6f64",
}

local palette = {
  grey = "#a89984",
  yellow = "#e9b143",
  green = "#b0b846",
  orange = "#f28534",
  red = "#f2594b",
  aqua = "#8bba7f",
  blue = "#80aa9e",
  purple = "#d3869b",
}

---Table to create special highlight groups.
local highlights = {
  StatusLine = { guifg = colors.active_fg, guibg = colors.active_bg },
  StatusLineNC = { guifg = colors.inactive_fg, guibg = colors.inactive_bg },
  StSpecialBuffer = {
    guifg = colors.active_fg,
    guibg = colors.active_bg,
    gui = "bold",
  },
}

---Create the highlight groups for the statusline from the given palette.
---This will create groups with names as 'St<colorname><attribute>' where
---colorname is Capitalized and attribute can be '', 'Bold' or 'Italic'
---@param prefix string (Default: 'St')
local function statusline_highlights(prefix)
  prefix = prefix or "St"
  for name, hex in pairs(palette) do
    name = name:gsub("^%l", string.upper)
    utils.highlight(prefix .. name, { guifg = hex, guibg = colors.active_bg })
    utils.highlight(prefix .. name .. "Bold", {
      guifg = hex,
      guibg = colors.active_bg,
      gui = "bold",
    })
    utils.highlight(prefix .. name .. "Italic", {
      guifg = hex,
      guibg = colors.active_bg,
      gui = "italic",
    })
  end

  ---Setting the special highlight groups.
  for hl_name, opts in pairs(highlights) do
    utils.highlight(hl_name, opts)
  end
end

---Wrap the highlight for statusline.
---@param hl string
---@return string
local function wrap_hl(hl)
  return hl and "%#" .. hl .. "#" or ""
end

---Special buffer information table.
---
---This includes the following components:
---types: List containing special buffer filetype or buftype.
---line: The line value to be displayed. It can be either a string or a
---      function where the `ctx` variable will be passed as the only argument.
---icon: Table containing the icon color and icon for the special buffer.
---
---Special buffers included in `types` but not in `line` means to make the line
---invisible using 'Normal' highlight group.
local special_buffer_info = {
  types = {
    "qf",
    "terminal",
    "help",
    "tsplayground",
    "NvimTree",
    "lir",
    "fugitive",
    "startify",
    "dashboard",
    "packer",
    "gitcommit",
    "vista_kind",
    "man",
    "cheat40",
  },
  line = {
    terminal = "Terminal",
    tsplayground = "TSPlayground",
    packer = "Packer",
    gitcommit = "Commit message",
    fugitive = "Fugitive",
    cheat40 = "Cheat40",

    qf = function(ctx)
      local list_type = fn.getwininfo(ctx.curwin)[1].loclist == 1
          and "Location"
        or "Quickfix"
      local title = vim.F.npcall(
        api.nvim_win_get_var,
        ctx.curwin,
        "quickfix_title"
      )
      title = title and "[" .. title .. "]" or ""
      return list_type .. " List " .. title .. "  %l/%L"
    end,

    help = function(ctx)
      local name = fn.fnamemodify(ctx.bufname, ":t:r")
      return "help [" .. name .. "]  %l/%L"
    end,

    lir = function(ctx)
      return "%<" .. fn.fnamemodify(ctx.bufname, ":~") .. " "
    end,

    vista_kind = function()
      return "Vista" .. " [" .. vim.g.vista.provider .. "]"
    end,

    man = function(ctx)
      local title = fn.fnamemodify(ctx.bufname, ":t")
      return "Man" .. " [" .. title .. "]  %l/%L"
    end,

    dashboard = function(ctx)
      return fn.fnamemodify(ctx.bufname, ":~:s?Dashboard??")
    end,
  },
  icon = {
    qf = { "StRed", icons.lists },
    terminal = { "StYellow", icons.terminal },
    help = { "StYellow", icons.info },
    tsplayground = { "StGreen", icons.tree },
    lir = { "StBlue", icons.directory },
    fugitive = { "StYellow", icons.git_logo },
    packer = { "StAqua", icons.package },
    gitcommit = { "StYellow", icons.git_commit },
    vista_kind = { "StBlue", icons.tag },
    man = { "StOrange", icons.book },
    dashboard = { "StBlue", icons.directory },
    cheat40 = { "StAqua", icons.tools },
  },
}

---Return the line information.
---Current format: total:col
---@param hl string
---@return string
local function lineinfo(hl)
  hl = wrap_hl(hl)
  return hl .. " %L:%-2c" .. " %*" -- ℓ 𝚌
end

---Return the file encoding and file format.
---@param hl string
---@return string
local function file_detail(ctx, hl)
  if api.nvim_win_get_width(ctx.curwin) < 100 then
    return ""
  end
  local encode = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
  local format = vim.bo.fileformat
  return " " .. wrap_hl(hl) .. encode:upper() .. " " .. format:upper() .. " %*"
end

---Return the Git branch name (requires fugitive.vim)
---@param hl string
---@return string
local function git_branch(hl)
  local FugitiveHead = vim.fn["FugitiveHead"]
  if FugitiveHead then
    local head = FugitiveHead()
    if head and head ~= "" then
      return " " .. wrap_hl(hl) .. icons.git_branch .. " " .. head .. "%* "
    end
  end
  return ""
end

---Return the Git diff count information (requires gitsigns.nvim)
---@param opts table
---@return string
local function git_diff_info(opts)
  local result = ""
  local status_dict = vim.b.gitsigns_status_dict
  if status_dict and not vim.tbl_isempty(status_dict) then
    for _, o in ipairs(opts) do
      local count = status_dict[o.field]
      if count and count > 0 then
        result = result .. wrap_hl(o.hl) .. o.icon .. " " .. count .. " %*"
      end
    end
  end
  return result
end

---Return the Python virtual environment name if we are in any.
---@param ctx table
---@return string
local function python_version(ctx, hl)
  if ctx.filetype == "python" then
    local env = os.getenv "VIRTUAL_ENV"
    local version = vim.g.current_python_version
    if env or version then
      env = env and "(" .. fn.fnamemodify(env, ":t") .. ") " or ""
      version = version and " " .. version .. " " or ""
      return wrap_hl(hl) .. version .. env .. "%*"
    end
  end
  return ""
end

---Return the number of GitHub notifications.
---@param hl string
---@return string
local function github_notifications(hl)
  local notifications = vim.g.github_notifications
  if notifications and notifications > 0 then
    return wrap_hl(hl) .. icons.github .. " " .. notifications .. " %*"
  end
  return ""
end

---Return the currently active neovim LSP client if any.
---@param ctx table
---@return string
local function lsp_clients(ctx, hl)
  local result = {}
  local clients = vim.lsp.buf_get_clients(ctx.curbuf)
  for id, client in pairs(clients) do
    table.insert(result, client.name .. ":" .. id)
  end

  if not vim.tbl_isempty(result) then
    result = table.concat(result, " ")
    return " " .. wrap_hl(hl) .. icons.rocket .. " " .. result .. "%* "
  else
    return ""
  end
end

---Return the diagnostics information for the given severity if > 0.
---@param ctx table
---@param opts table
---@return string
local function lsp_diagnostics(ctx, opts)
  local curbuf = ctx.curbuf
  local result = ""
  for _, o in ipairs(opts) do
    local count = vim.lsp.diagnostic.get_count(curbuf, o.severity)
    if count > 0 then
      result = result .. wrap_hl(o.hl) .. o.icon .. " " .. count .. " %*"
    end
  end
  return result ~= "" and " " .. result or result
end

---Return the current function value from the LSP server.
---@param hl string
---@return string
local function lsp_current_function(hl)
  local current_function = vim.b.lsp_current_function
  if current_function and current_function ~= "" then
    return wrap_hl(hl) .. " " .. current_function .. " %*"
  end
  return ""
end

---Neovim LSP messages
---@param hl string
---@return string
local function lsp_messages(hl)
  local message = vim.g.lsp_progress_message
  if message and message ~= "" then
    return wrap_hl(hl) .. message .. " %*"
  end
  return ""
end

---Create the statusline for the inactive buffer.
---@param ctx table
---@return string
local function inactive_statusline(ctx, prefix)
  local extension = fn.fnamemodify(ctx.bufname, ":e")
  local filename = fn.fnamemodify(ctx.bufname, ":p:t")
  local icon, _ = devicons.get_icon(filename, extension, { default = true })
  return prefix
    .. " "
    .. icon
    .. " %<"
    .. fn.fnamemodify(ctx.bufname, ":~:.")
    .. " "
end

---Determine whether we are in a special buffer or not.
---@param ctx table
---@return boolean
local function special_buffer(ctx)
  return contains(special_buffer_info.types, ctx.filetype) or contains(
    special_buffer_info.types,
    ctx.buftype
  )
end

---Returns the name of the special buffer as per the name table values of
---the special_buffer_info variable.
---@param ctx table
---@param typ string
---@return string
local function special_buffer_line(ctx, typ)
  local line = special_buffer_info.line[typ] or ""
  if type(line) == "function" then
    return line(ctx)
  else
    return line
  end
end

---Return the statusline for special builtin buffers such as Quickfix, Terminal
---and plugin buffers such as NvimTree, TSPlayground, etc.
---@param ctx table
---@param inactive boolean
---@return string
local function special_buffer_statusline(ctx, inactive, prefix)
  local typ = ctx.filetype ~= "" and ctx.filetype or ctx.buftype
  local line = special_buffer_line(ctx, typ)

  -- If there is no line registered but the buffer is considered to be special,
  -- then we will make the line invisible.
  if line == "" then
    return wrap_hl "Normal"
  end

  local color, icon = unpack(special_buffer_info.icon[typ] or { "", "" })
  local hl = inactive and "" or wrap_hl(color)
  local name_hl = inactive and "" or wrap_hl "StSpecialBuffer"

  return prefix .. " " .. hl .. icon .. "%* " .. name_hl .. line
end

---Provide the statusline for different types of buffers including active,
---inactive, special buffers such as NvimTree, Terminal, quickfix, etc.
---@return string
function _G.nvim_statusline()
  local prefix = "▌"
  local curwin = vim.g.statusline_winid or 0
  local curbuf = api.nvim_win_get_buf(curwin)
  local curbo = vim.bo[curbuf]
  local inactive = api.nvim_get_current_win() ~= curwin

  local ctx = {
    curwin = curwin,
    curbuf = curbuf,
    bufname = fn.bufname(curbuf),
    filetype = curbo.filetype,
    buftype = curbo.buftype,
    inactive = inactive,
  }

  if special_buffer(ctx) then
    return special_buffer_statusline(ctx, inactive, prefix)
  elseif inactive then
    return inactive_statusline(ctx, prefix)
  end

  return wrap_hl "StAqua"
    .. prefix
    .. "%*"
    .. lineinfo "StSpecialBuffer"
    .. git_branch "StGreenBold"
    .. "%<"
    .. lsp_current_function "StGrey"
    .. "%="
    .. github_notifications "StGrey"
    .. python_version(ctx, "StBlueBold")
    .. lsp_clients(ctx, "StGreenBold")
    .. lsp_messages "StGrey"
    .. file_detail(ctx, "StGreyBold")
    .. lsp_diagnostics(ctx, {
      { severity = "Information", icon = icons.info, hl = "StBlue" },
      { severity = "Hint", icon = icons.hint, hl = "StAqua" },
      { severity = "Warning", icon = icons.warning, hl = "StYellow" },
      { severity = "Error", icon = icons.error, hl = "StRed" },
    })
end

---Create a timer for the given task and interval.
---@param interval number (ms)
---@param task function
local function job(interval, task)
  -- A one-shot job to initialize the data
  vim.defer_fn(task, 100)
  ---@type number
  local pending_job
  -- Start the job every `interval` milliseconds ad infinitum
  fn.timer_start(interval, function()
    if pending_job then
      fn.jobstop(pending_job)
    end
    pending_job = task()
  end, {
    ["repeat"] = -1,
  })
end

---Function to start a job which sets the current Python version.
local function set_python_version()
  fn.jobstart("python --version", {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and data[1] ~= "" then
        vim.g.current_python_version = data[1]
      end
    end,
  })
end

---Function to start a job which sets the number of GitHub notifications.
local function fetch_github_notifications()
  fn.jobstart("gh api notifications", {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and data[1] ~= "" then
        local notifications = vim.fn.json_decode(data)
        vim.g.github_notifications = #notifications
      end
    end,
  })
end

local function python_version_job()
  if fn.executable "python" > 0 then
    job(5 * 1000, set_python_version)
  end
end

local function github_notifications_job()
  if fn.executable "gh" > 0 then
    job(5 * 60 * 1000, fetch_github_notifications)
  end
end

-- Define the necessary autocmds
dm.augroup("custom_statusline", {
  {
    events = { "VimEnter", "ColorScheme" },
    targets = "*",
    command = statusline_highlights,
  },
  {
    events = "FileType",
    targets = "python",
    command = python_version_job,
  },
  {
    events = "VimEnter",
    targets = "*",
    command = github_notifications_job,
  },
})

do
  local timeout = 1000
  local clear_message_timer

  local function format_data(data)
    local message
    if data.progress then
      message = data.title
      if data.message then
        message = message .. " " .. data.message
      end
      if data.percentage then
        message = message .. string.format(" (%.0f%%%%)", data.percentage)
      end
    else
      message = data.content
    end
    return message
  end

  local function on_progress_update()
    local messages = vim.lsp.util.get_progress_messages()
    for _, data in ipairs(messages) do
      vim.g.lsp_progress_message = format_data(data)
    end
    if clear_message_timer then
      clear_message_timer:stop()
    end
    -- Reset the variable to clear the statusline.
    clear_message_timer = vim.defer_fn(function()
      vim.g.lsp_progress_message = nil
      clear_message_timer = nil
    end, timeout)
  end

  dm.autocmd {
    group = "custom_statusline",
    events = "User LspProgressUpdate",
    command = on_progress_update,
  }
end

-- :h qf.vim, disable quickfix statusline
vim.g.qf_disable_statusline = 1

-- Set the statusline
vim.o.statusline = "%!v:lua.nvim_statusline()"
