---@see https://github.com/fsouza/dotfiles/blob/main/nvim/lua/fsouza/lsp/locations.lua
local M = {}

local api = vim.api
local lsp = vim.lsp

local highlighter = require 'nvim-treesitter.highlight'

-- Table consisting of treesitter node types to use for preview.
local node_types = {
  -- go
  'function_declaration',
  'method_declaration',
  'type_declaration',
  'var_declaration',

  -- lua
  'program', -- preview the entire module
  'function', -- for method nodes like `class:method()`
  'local_function',
  'variable_declaration', -- `f = function(...) ... end`
  'local_variable_declaration', -- `local f = function(...) ... end`

  -- python
  'module', -- preview the entire module
  'class_definition',
  'function_definition',
  'expression_statement',
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

-- Update the location range from the LSP using treesitter.
---@generic T
---@param location T
---@return T #updated location or the default location if node is not found
---@return number #bufnr of file containing the location.
local function ts_range(location)
  local uri = location.targetUri or location.uri
  local range = location.targetRange or location.range
  if not uri then
    return location
  end

  -- This will add the buffer to the buffer list. We don't want to attach the
  -- language server to that buffer, so we will ignore all events when setting
  -- the filetype and getting the parser for the buffer.
  vim.o.eventignore = 'all'
  local bufnr = vim.uri_to_bufnr(uri)
  vim.bo[bufnr].filetype = vim.bo.filetype
  local parser = vim.treesitter.get_parser(bufnr)
  vim.o.eventignore = ''

  -- This will return a table of trees.
  local tree = parser:parse()[1]
  if not tree then
    return location
  end

  local root = tree:root()
  local lsp_start_pos = range.start
  local lsp_end_pos = range['end']
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
      range.start.line = ts_start_line
      range.start.character = ts_start_col
      range['end'].line = ts_end_line
      range['end'].character = ts_end_col
      break
    end
    node = node:parent()
    if not node then
      break
    end
    ts_start_line, ts_start_col, ts_end_line, ts_end_col = node:range()
  end

  location.range = range
  return location, bufnr
end

-- Handler for the preview location request.
---@param result table[]|table|nil
---@param ctx table
local function preview_location_handler(_, result, ctx)
  if not result or vim.tbl_isempty(result) then
    dm.notify('LSP Preview (' .. ctx.method .. ')', 'No results found')
    return
  end

  local location_bufnr
  local location = vim.tbl_islist(result) and result[1] or result
  location, location_bufnr = ts_range(location)

  local bufnr, winnr = lsp.util.preview_location(location)
  highlighter.attach(bufnr, vim.bo.filetype)

  -- This will be used to avoid re-requesting and thus avoid attaching the
  -- highlighter again to the buffer which results in an error.
  vim.b.dm__lsp_preview_window = winnr

  -- Delete the buffer if its not the current buffer. This is done because it
  -- was only used to get the location using treesitter and now it is of no
  -- need to us.
  if api.nvim_get_current_buf() ~= location_bufnr then
    api.nvim_buf_delete(location_bufnr, { force = true })
  end
end

-- Factory function to create a preview callback.
---@param method string The LSP method to use for getting the location.
---@return function #A callback function to be used with a keymap.
local function make_lsp_preview_action(method)
  return function()
    local existing_float = vim.b.dm__lsp_preview_window
    if existing_float and api.nvim_win_is_valid(existing_float) then
      api.nvim_set_current_win(existing_float)
    end
    local params = lsp.util.make_position_params()
    lsp.buf_request(0, method, params, preview_location_handler)
  end
end

M.definition = make_lsp_preview_action 'textDocument/definition'
M.declaration = make_lsp_preview_action 'textDocument/declaration'
M.implementation = make_lsp_preview_action 'textDocument/implementation'
M.type_definition = make_lsp_preview_action 'textDocument/typeDefinition'

return M
