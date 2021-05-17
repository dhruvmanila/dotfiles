local api = vim.api
local lsp = vim.lsp
local icons = require("core.icons")
local utils = require("core.utils")

local severity_icon = { icons.error, icons.warning, icons.info, icons.hint }
local severity_hl = {
  "LspDiagnosticsFloatingError",
  "LspDiagnosticsFloatingWarning",
  "LspDiagnosticsFloatingInformation",
  "LspDiagnosticsFloatingHint",
}

-- Configuration for diagnostics window.
local config = {
  show_header = true,
  show_source = true,
  header_hl = "Fg",
  source_hl = "Comment",
  pad_left = 1, -- with spaces
  pad_right = 1, -- with spaces
}

local M = {}

-- Return the formatted string using diagnostic information.
--   `<pad_left><icon> <message>[ <source>]<pad_right>`
---@param diagnostic table
---@return string
local function diagnostic_line(diagnostic)
  local source = (config.show_source and diagnostic.source)
      and " [" .. diagnostic.source:gsub("%.$", "") .. "]"
    or ""

  return string.format(
    "%s%s %s%s%s",
    string.rep(" ", config.pad_left),
    severity_icon[diagnostic.severity],
    diagnostic.message:gsub("\n", " "),
    source,
    string.rep(" ", config.pad_right)
  )
end

-- Show the current line diagnostics in a pretty format :)
function M.show_line_diagnostics()
  local current_bufnr = api.nvim_get_current_buf()
  local linenr = api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = lsp.diagnostic.get_line_diagnostics(current_bufnr, linenr)

  if vim.tbl_isempty(diagnostics) then
    return
  end

  local lines = {}
  local longest_line = 0
  for _, diagnostic in ipairs(diagnostics) do
    local line = diagnostic_line(diagnostic)
    table.insert(lines, line)
    longest_line = math.max(longest_line, api.nvim_strwidth(line))
  end

  local bufnr = api.nvim_create_buf(false, true)
  local current_row = 0

  if config.show_header then
    local header = string.format(" %s Diagnostics:", icons["list-ordered"])
    utils.append(bufnr, { header }, config.header_hl)
    utils.append(bufnr, { string.rep("─", longest_line) }, "Grey")
    current_row = current_row + 2
  end

  for i, line in ipairs(lines) do
    utils.append(bufnr, { line }, severity_hl[diagnostics[i].severity])
    local start, _ = line:find(
      "%[.*%]" .. string.rep(" ", config.pad_right) .. "$"
    )
    api.nvim_buf_add_highlight(
      bufnr,
      -1,
      config.source_hl,
      current_row,
      start - 1,
      -1
    )
    current_row = current_row + 1
  end
  -- Remove the last blank line
  api.nvim_buf_set_lines(bufnr, -2, -1, false, {})

  api.nvim_buf_set_option(bufnr, "modifiable", false)
  api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  local win_opts = utils.make_floating_popup_options(
    longest_line,
    current_row,
    true -- border will be inserted by neovim
  )
  win_opts.border = icons.border.edge
  local winnr = api.nvim_open_win(bufnr, false, win_opts)

  lsp.util.close_preview_autocmd({
    "CursorMoved",
    "CursorMovedI",
    "BufHidden",
    "BufLeave",
    "WinScrolled",
  }, winnr)
end

return M
