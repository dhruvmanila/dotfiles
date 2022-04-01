-- Statusline and tabline providers. These are kept in separate module as
-- they're common to both.
local M = {}

local fn = vim.fn
local api = vim.api

-- Provide the buffer flags.
-- Supported flags: Readonly, modified.
---@param bufnr? number
---@return string
function M.buffer_flags(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local bo = vim.bo[bufnr]
  if bo.readonly then
    return ' '
  elseif bo.modifiable and bo.buftype ~= 'prompt' then
    if bo.modified then
      return ' ●'
    end
  end
  return ''
end

-- Provide the buffer name as per its type and optionally, modify it using
-- the given modifier.
---@param bufnr? number
---@param modifier? string
function M.buffer_name(bufnr, modifier)
  bufnr = bufnr or api.nvim_get_current_buf()
  local name = api.nvim_buf_get_name(bufnr)
  local buftype = api.nvim_buf_get_option(bufnr, 'buftype')
  if buftype == 'terminal' then
    -- Extract the command part from the terminal title.
    -- Pattern: 'term://{pwd}//{pid}:{cmd} {args}'
    name = name:match '^term://.*//%d+:([^ ]+)'
    modifier = ':t'
  elseif buftype == 'help' then
    modifier = ':t'
  elseif buftype == 'prompt' then
    name = '[Prompt]'
  elseif buftype == 'quickfix' then
    name = '[Quickfix List]'
  elseif name == '' then
    name = '[No Name]'
  end
  if modifier then
    name = fn.fnamemodify(name, modifier)
  end
  return name
end

return M
