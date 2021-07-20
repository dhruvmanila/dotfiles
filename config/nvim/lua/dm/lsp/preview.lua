-- Ref: https://github.com/fsouza/dotfiles/blob/main/nvim/lua/fsouza/lsp/locations.lua
local M = {}

local highlighter = require "nvim-treesitter.highlight"

-- Table consisting of treesitter node types to use for preview.
local node_types = {
  -- lua
  "program", -- preview the entire module
  "function", -- for method nodes like `class:method()`
  "local_function",
  "variable_declaration", -- `f = function(...) ... end`
  "local_variable_declaration", -- `local f = function(...) ... end`

  -- python
  "module", -- preview the entire module
  "class_definition",
  "function_definition",
}

-- Determine whether this is the node to be used for treesitter range.
---@return boolean
local function should_use_ts(node)
  if node == nil then
    return false
  end
  return vim.tbl_contains(node_types, node:type())
end

-- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#location
-- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#locationLink

-- Get the range of the location node using treesitter.
---@param location table
---@return table
---@return number
local function ts_range(location)
  location.uri = location.targetUri or location.uri
  location.range = location.targetRange or location.range
  if not location.uri then
    return location
  end

  -- This will add the buffer to the buffer list. We don't want to attach the
  -- language server to that buffer, so we will ignore all events when setting
  -- the filetype and getting the parser for the buffer.
  vim.o.eventignore = "all"
  local bufnr = vim.uri_to_bufnr(location.uri)
  vim.bo[bufnr].filetype = vim.bo.filetype
  local parser = vim.treesitter.get_parser(bufnr)
  vim.o.eventignore = ""

  local _, tree = next(parser:trees())
  if not tree then
    return location
  end

  local root = tree:root()
  local lsp_start_pos = location.range.start
  local lsp_end_pos = location.range["end"]
  local node = root:named_descendant_for_range(
    lsp_start_pos.line,
    lsp_start_pos.character,
    lsp_end_pos.line,
    lsp_end_pos.character
  )

  -- We're going to keep climbing up the tree for the **same line** until we get
  -- the node we want which is listed out in `node_types`, otherwise we will
  -- return the default location.
  node = node:parent()
  local ts_start_line, ts_start_col, ts_end_line, ts_end_col = node:range()
  while ts_start_line == lsp_start_pos.line do
    if should_use_ts(node) then
      location.range.start.line = ts_start_line
      location.range.start.character = ts_start_col
      location.range["end"].line = ts_end_line
      location.range["end"].character = ts_end_col
      break
    end
    node = node:parent()
    if not node then
      break
    end
    ts_start_line, ts_start_col, ts_end_line, ts_end_col = node:range()
  end

  return location, bufnr
end

local function preview_location_callback(_, method, response)
  if not response or vim.tbl_isempty(response) then
    vim.notify("LSP (" .. method .. "): No results found")
    return
  end

  local location_bufnr
  local location = vim.tbl_islist(response) and response[1] or response
  location, location_bufnr = ts_range(location)

  local bufnr, winnr = vim.lsp.util.preview_location(location)
  highlighter.attach(bufnr, vim.bo.filetype)

  -- This will be used to avoid re-requesting and thus avoid attaching the
  -- highlighter again to the buffer which results in an error.
  vim.b.dm__lsp_preview_window = winnr

  -- We are deleting the buffer because it was only used to get the location
  -- using treesitter and now it is of no need to us.
  vim.api.nvim_buf_delete(location_bufnr, { force = true })
end

local function make_lsp_preview_action(method)
  return function()
    local existing_float = vim.b.dm__lsp_preview_window
    if existing_float and vim.api.nvim_win_is_valid(existing_float) then
      vim.api.nvim_set_current_win(existing_float)
    end
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, method, params, preview_location_callback)
  end
end

M.definition = make_lsp_preview_action "textDocument/definition"
M.declaration = make_lsp_preview_action "textDocument/declaration"
M.implementation = make_lsp_preview_action "textDocument/implementation"
M.type_definition = make_lsp_preview_action "textDocument/typeDefinition"

return M
