local M = {}

local api = vim.api
local lsp = vim.lsp
local icons = dm.icons
local Text = require "dm.text"
local utils = require "dm.utils"

local severity_signs = { icons.error, icons.warning, icons.info, icons.hint }
local severity_hl = {
  "DiagnosticFloatingError",
  "DiagnosticFloatingWarn",
  "DiagnosticFloatingInfo",
  "DiagnosticFloatingHint",
}

-- Configuration for the diagnostics window.
local config = {
  show_source = true,
  show_code = true,
  meta_hl = "GreyItalic", -- Highlight group for source and code
  timeout = 200, -- Time(ms) after which to display the diagnostics
}

local function show_line_diagnostics()
  local existing_float = vim.b.lsp_floating_preview
  if existing_float and api.nvim_win_is_valid(existing_float) then
    return
  end

  local current_bufnr = api.nvim_get_current_buf()
  local linenr = api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = lsp.diagnostic.get_line_diagnostics(current_bufnr, linenr)

  if vim.tbl_isempty(diagnostics) then
    return
  end

  local bufnr = api.nvim_create_buf(false, true)
  local text = Text:new(bufnr)

  for _, diagnostic in ipairs(diagnostics) do
    local prefix = " " .. severity_signs[diagnostic.severity] .. " "
    local hl = severity_hl[diagnostic.severity]
    local message_lines = vim.split(diagnostic.message, "\n", true)
    text:add(prefix, hl)
    text:add(message_lines[1], hl)
    if config.show_source and diagnostic.source then
      text:add(" " .. diagnostic.source, config.meta_hl)
    end
    if config.show_code and diagnostic.code then
      text:add(" (" .. diagnostic.code .. ")", config.meta_hl)
    end
    text:newline()
    -- Adds indentation that matches the prefix length to ensure diagnostic
    -- messages spawning multiple lines align.
    prefix = string.rep(" ", #prefix)
    for j = 2, #message_lines do
      text:add(prefix .. message_lines[j], hl, true)
    end
  end

  api.nvim_buf_set_option(bufnr, "modifiable", false)
  api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  local win_opts = utils.make_floating_popup_options(
    text.longest_line,
    text.line,
    dm.border[vim.g.border_style]
  )
  local winnr = api.nvim_open_win(bufnr, false, win_opts)

  lsp.util.close_preview_autocmd({
    "CursorMoved",
    "CursorMovedI",
    "BufHidden",
    "BufLeave",
    "WinScrolled",
  }, winnr)
end

do
  -- The timer used for displaying the diagnostics in a floating window.
  local diagnostics_timer

  -- Show the current line diagnostics in a floating window with an icon,
  -- message and optionally source and code information.
  function M.show_line_diagnostics()
    if diagnostics_timer then
      diagnostics_timer:stop()
    end

    diagnostics_timer = vim.defer_fn(show_line_diagnostics, config.timeout)
  end
end

return M
