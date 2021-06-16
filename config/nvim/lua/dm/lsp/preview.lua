-- Ref: https://github.com/fsouza/dotfiles/blob/main/nvim/lua/fsouza/lsp/locations.lua
local M = {}

local lsp = vim.lsp
local parsers = require "nvim-treesitter.parsers"

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

-- Normalize Location/LocationLink to Location.
---@param location table
---@return table
---@see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#location
---@see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#locationLink
local function normalize_location(location)
  if location.uri then
    return location
  end
  if location.targetUri then
    location.uri = location.targetUri
    if location.targetRange then
      location.range = location.targetRange
    end
  end
  return location
end

-- Get the range of the location node using treesitter.
---@param location table
---@return table
local function ts_range(location)
  location = normalize_location(location)
  local bufnr = vim.uri_to_bufnr(location.uri)
  -- Set the filetype to activate the parser for the respective buffer.
  vim.bo[bufnr].filetype = vim.bo.filetype

  local parser = parsers.get_parser(bufnr)
  if not parser then
    return location
  end

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
  return location
end

local function preview_location_callback(_, method, response)
  if not response or vim.tbl_isempty(response) then
    print(string.format("[LSP] No results found for: %s", method))
    return
  end
  local location = vim.tbl_islist(response) and response[1] or response
  location = ts_range(location)
  local bufnr, _ = lsp.util.preview_location(location)
  -- Set the filetype for treesitter highlights.
  vim.bo[bufnr].filetype = vim.bo.filetype
end

local function make_lsp_preview_action(method)
  return function()
    local params = lsp.util.make_position_params()
    lsp.buf_request(0, method, params, preview_location_callback)
  end
end

M.definition = make_lsp_preview_action "textDocument/definition"
M.declaration = make_lsp_preview_action "textDocument/declaration"
M.implementation = make_lsp_preview_action "textDocument/implementation"
M.type_definition = make_lsp_preview_action "textDocument/typeDefinition"

return M
