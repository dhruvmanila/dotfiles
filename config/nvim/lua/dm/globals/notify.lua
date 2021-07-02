-- Ref: https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/globals.lua

local api = vim.api

-- Available log levels
---@alias levels
---|'0' # Trace
---|'1' # Debug
---|'2' # Information
---|'3' # Warning
---|'4' # Error

local function validate_notification(msg, log_level, opts)
  vim.validate {
    msg = {
      msg,
      function(a)
        local atype = type(a)
        return atype == "string" or atype == "table"
      end,
      "a string or table",
    },
    log_level = { log_level, "n", true },
    opts = { opts, "t", true },
  }
end

local level_suffix = {
  [1] = "Hint",
  [2] = "Information",
  [3] = "Warning",
  [4] = "Error",
}

-- Return the notification window highlight groups as per the given log level.
---@param level levels
---@return string[]
local function notification_hl(level)
  local suffix = level_suffix[level]
  if suffix then
    return {
      "FloatBorder:LspDiagnosticsFloating" .. suffix,
      "NormalFloat:LspDiagnosticsFloating" .. suffix,
    }
  end
  return { "FloatBorder:TabLineSel", "NormalFloat:Normal" }
end

-- Return the window configuration for the previous notification window, if
-- any are present.
---@return table?
local function get_last_notification()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "vim-notify" and api.nvim_win_is_valid(win) then
      return api.nvim_win_get_config(win)
    end
  end
end

-- Open a floating window to display the notification lines.
-- This will also make sure that if any other notification window is already
-- opened, the next will be opened right on top of it.
---@param lines string|string[]
---@param opts table
local function notify(lines, opts)
  lines = type(lines) == "string" and { lines } or lines
  lines = vim.tbl_flatten(vim.tbl_map(function(line)
    return vim.split(line, "\n")
  end, lines))
  local highlights = notification_hl(opts.log_level)

  local width = 0
  for i, line in ipairs(lines) do
    line = " " .. line .. " "
    lines[i] = line
    width = math.max(width, #line)
  end
  local prev = get_last_notification()
  local row = prev and prev.row[false] - prev.height - 2
    or vim.o.lines - vim.o.cmdheight - 3

  local bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  local winnr = api.nvim_open_win(bufnr, false, {
    relative = "editor",
    width = width + 2,
    height = #lines,
    col = vim.o.columns - 3,
    row = row,
    anchor = "SE",
    style = "minimal",
    focusable = false,
    border = "rounded",
  })

  vim.bo[bufnr].filetype = "vim-notify"
  vim.wo[winnr].wrap = true
  vim.wo[winnr].winhighlight = table.concat(highlights, ",")

  vim.defer_fn(function()
    if api.nvim_win_is_valid(winnr) then
      api.nvim_win_close(winnr, true)
    end
  end, opts.timeout)
end

-- Override the default `vim.notify` to open a floating window.
---@param msg string|string[] text in the notification window
---@param log_level? levels
---@param opts? table options such as timeout, etc
vim.notify = function(msg, log_level, opts)
  validate_notification(msg, log_level, opts)
  log_level = log_level or 1
  local timeout = opts and opts.timeout or 5000
  notify(msg, { log_level = log_level, timeout = timeout })
end
