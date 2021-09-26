local M = {}

local api = vim.api
local if_nil = vim.F.if_nil
local log = dm.log
local job = require "dm.job"

-- Types {{{

---@class Formatter
---@field enable? fun():boolean enable/disable formatter for current file
---@field cmd string formatter command
---@field args? string[]|fun():string[] arguments to pass
---@field use_lsp boolean use the LSP provided formatter
---@field opts table LSP formatting options

---@class Format
---@field bufnr number
---@field formatters Formatter[]
---@field input string[]
---@field output string[]
---@field changedtick number
---@field tempfile_name string

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
function Format:new(formatters)
  local bufnr = api.nvim_get_current_buf()
  local input = api.nvim_buf_get_lines(bufnr, 0, -1, false)

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
  job {
    cmd = formatter.cmd,
    args = formatter.args,
    writer = self.output,
    on_exit = function(result)
      if result.code > 0 then
        log.error(result.stderr)
        return self:step()
      end
      self.output = vim.fn.split(result.stdout, "\n")
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
function Format:lsp_run(formatter)
  vim.lsp.buf_request(
    self.bufnr,
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params(formatter.opts),
    function(err, result)
      if err then
        log.error(err.message)
        return
      end
      if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
        log.warn "Skipping formatting, buffer was changed"
        return
      end
      if result then
        vim.lsp.util.apply_text_edits(result, self.bufnr)
        self:write()
      end
    end
  )
end

-- Format:step {{{1

-- A helper function to bridge the gap between running multiple formatters
-- asynchronously because a simple `for` loop won't cut it.
--
-- If there are no formatters, then we're done, otherwise check whether the
-- formatter is enabled for the current buffer and run it, otherwise run the
-- next one.
function Format:step()
  if #self.formatters == 0 then
    return self:done()
  end
  local formatter = table.remove(self.formatters, 1)
  -- Just `f()` is not a tail call, not that it makes a difference here.
  -- This is because lua still have to discard the result of the call and then
  -- return nil. `f()` is similar to `f(); return` instead of `return f()`
  if formatter.enable() then
    if formatter.use_lsp then
      return self:lsp_run(formatter)
    end
    return self:run(formatter)
  else
    return self:step()
  end
end

-- Format:done {{{1

function Format:done()
  if self.changedtick ~= api.nvim_buf_get_changedtick(self.bufnr) then
    log.warn "Skipping formatting, buffer was changed"
    return
  end
  if vim.deep_equal(self.input, self.output) then
    return
  end
  if vim.tbl_isempty(self.output) then
    log.warn "Skipping formatting, received empty output"
  else
    -- Folds are removed when formatting is done, so we save the current state
    -- of the view and re-apply it manually after formatting the buffer.
    vim.cmd "mkview!"
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.output)
    self:write()
    vim.cmd "loadview"
  end
end

-- Format:write {{{1

-- Write the output to the buffer without triggering the formatter again.
function Format:write()
  format_write = true
  api.nvim_command "update"
  format_write = false
end

-- }}}1

-- Register the formatters for the given filetype.
---@param filetype string
---@param formatters Formatter|Formatter[]
function M.register(filetype, formatters)
  formatters = vim.tbl_islist(formatters) and formatters or { formatters }
  if not registered_formatters[filetype] then
    registered_formatters[filetype] = {}
  end

  for _, formatter in ipairs(formatters) do
    -- By default, every formatter is enabled.
    formatter.enable = if_nil(formatter.enable, function()
      return true
    end)
    formatter.use_lsp = if_nil(formatter.use_lsp, false)
    formatter.opts = formatter.opts or {}
    table.insert(registered_formatters[filetype], formatter)
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
  return Format:new(formatters):step()
end

-- For debugging purposes.
M._registered_formatters = registered_formatters

return M
