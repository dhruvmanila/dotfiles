local M = {}

local api = vim.api
local log = require 'dm.log'
local job = require 'dm.job'

-- Types {{{

---@class Formatter
---@field enable? fun():boolean enable/disable the formatter, (default: enabled)
---@field cmd? string formatter command (default: nil)
---@field args? string[]|fun():string[] arguments to pass (default: nil)
---@field lsp? { format?: boolean, opts?: table, code_actions?: string[] }

---@class Format
---@field bufnr number
---@field formatters Formatter[]
---@field input string[]
---@field output string[]
---@field changedtick number

-- }}}

-- A flag to signal that the `BufWritePost` was triggered by the `Format`
-- command when it tries to `update` the buffer.
--
-- This is done to let other commands run for this event such as linting,
-- and to prevent the formatter to go into an infinite loop.
---@type boolean
local format_write = false

---@type table<string, Formatter[]>
local registered_formatters = {}

---@type Format
local Format = {}
Format.__index = Format

-- Format:new {{{1

-- Initiate the format process for the given formatters.
---@param formatters Formatter[]
---@return Format
function Format:new(bufnr, input, formatters)
  return setmetatable({
    bufnr = bufnr,
    formatters = vim.deepcopy(formatters),
    input = input,
    output = input,
    changedtick = api.nvim_buf_get_changedtick(bufnr),
  }, self)
end

-- Format:run {{{1

-- Run the given formatter asynchronously.
---@param formatter Formatter
function Format:run(formatter)
  local args = formatter.args
  if type(args) == 'function' then
    args = args(self.bufnr)
  end

  job {
    cmd = formatter.cmd,
    args = args,
    writer = self.output,
    on_exit = function(result)
      if result.code > 0 then
        log.error(result.stderr)
        return self:step()
      end
      self.output = vim.split(result.stdout, '\n', { trimempty = true })
      return self:step()
    end,
  }
end

-- Format:run_lsp {{{1

-- Run the formatter from the LSP client.
-- This assumes that the formatting requested from a client attached to the
-- buffer has the ability to do so and there is only one client capable of
-- performing the request.
---@param formatter Formatter
function Format:run_lsp(formatter)
  vim.lsp.buf_request(
    self.bufnr,
    'textDocument/formatting',
    vim.lsp.util.make_formatting_params(formatter.lsp.opts),
    function(err, result, ctx)
      if err then
        log.error(err.message)
        return
      end
      if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
        log.warn 'Skipping formatting, buffer was changed'
        return
      end
      if result then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_text_edits(
          result,
          self.bufnr,
          client.offset_encoding
        )
        self:write()
      end
    end
  )
end

-- Format:run_code_actions {{{1

-- Execute the provided code actions for all the LSP clients synchronously.
---@param code_actions string[]
function Format:run_code_actions(code_actions)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = code_actions }
  local responses, err = vim.lsp.buf_request_sync(
    self.bufnr,
    'textDocument/codeAction',
    params,
    1000 -- timeout (ms)
  )
  if responses == nil then
    return log.error(err)
  end

  local executed = false
  for client_id, response in pairs(responses) do
    if not vim.tbl_isempty(response) then
      local action = response.result[1]
      local client = vim.lsp.get_client_by_id(client_id)
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        executed = true
      end
    end
  end

  if executed then
    self:write()
    self:update_state()
  end
end

-- Format:step {{{1

-- A helper function to bridge the gap between running multiple formatters
-- asynchronously because a simple `for` loop won't cut it.
--
-- If there are no formatters, then we're done, otherwise check whether the
-- formatter is enabled for the current buffer and run it, otherwise run the
-- next one.
function Format:step()
  if vim.tbl_isempty(self.formatters) then
    return self:done()
  end
  ---@type Formatter
  local formatter = table.remove(self.formatters, 1)
  -- By default, every formatter is on.
  if formatter.enable == nil or formatter.enable(self.bufnr) then
    if formatter.cmd == nil then
      if formatter.lsp.code_actions ~= nil then
        self:run_code_actions(formatter.lsp.code_actions)
      end
      if formatter.lsp.format then
        return self:run_lsp(formatter)
      end
    else
      return self:run(formatter)
    end
  else
    return self:step()
  end
end

-- Format:done {{{1

function Format:done()
  if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
    log.warn 'Skipping formatting, buffer was changed'
  elseif vim.tbl_isempty(self.output) then
    log.warn 'Skipping formatting, received empty output'
  elseif vim.deep_equal(self.input, self.output) then
    log.debug 'Skipping formatting, input left unchanged'
  else
    local view = vim.fn.winsaveview()
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.output)
    vim.fn.winrestview(view)
    self:write()
  end
end

-- Format:write {{{1

-- Write the output to the buffer without triggering the formatter again.
function Format:write()
  format_write = true
  api.nvim_command 'update'
  format_write = false
end

-- Format:update_state {{{1

-- Update the state of the format runner. This should be called only when the
-- buffer is updated by the LSP client, so that other formatters are aware of
-- the updated buffer.
function Format:update_state()
  self.changedtick = api.nvim_buf_get_changedtick(self.bufnr)
  self.input = api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  self.output = self.input
end

-- }}}1

-- Register the formatters for the given filetypes.
---@param filetypes string|string[]
---@param formatters Formatter|Formatter[]
function M.register(filetypes, formatters)
  filetypes = vim.tbl_islist(filetypes) and filetypes or { filetypes }
  formatters = vim.tbl_islist(formatters) and formatters or { formatters }

  for _, filetype in ipairs(filetypes) do
    if not registered_formatters[filetype] then
      registered_formatters[filetype] = {}
    end

    for _, formatter in ipairs(formatters) do
      formatter.lsp = formatter.lsp or {}
      formatter.lsp.format = vim.F.if_nil(formatter.lsp.format, false)
      if formatter.cmd and formatter.lsp.format then
        log.fmt_warn(
          'LSP client and external command cannot be used in the same formatter '
            .. "spec in '%s'. Please separate them out.",
          filetype
        )
      elseif not (formatter.cmd or formatter.lsp.format) then
        log.fmt_warn(
          'Please provide either an external command to run or enable formatting '
            .. "through the LSP client. Both are disabled for '%s'.",
          filetype
        )
      else
        table.insert(registered_formatters[filetype], formatter)
      end
    end
  end
end

function M.format()
  if format_write or not vim.bo.modifiable then
    return
  end
  local formatters = registered_formatters[vim.bo.filetype]
  if not formatters then
    return
  end
  local bufnr = api.nvim_get_current_buf()
  local input = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #input == 1 and input[1] == '' then
    return
  end
  return Format:new(bufnr, input, formatters):step()
end

-- For debugging purposes.
M._registered_formatters = registered_formatters

return M
