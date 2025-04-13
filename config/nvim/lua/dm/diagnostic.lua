local M = {}

local namespace = vim.api.nvim_create_namespace 'dm__virtual_line_diagnostics'

---@enum ElementKind
local ElementKind = {
  Space = 1,
  Diagnostic = 2,
  Overlap = 3,
  Blank = 4,
}

-- The highlight groups for each severity level to be used in the virtual lines.
local highlight_map = {
  [vim.diagnostic.severity.ERROR] = 'DiagnosticVirtualLinesError',
  [vim.diagnostic.severity.WARN] = 'DiagnosticVirtualLinesWarn',
  [vim.diagnostic.severity.INFO] = 'DiagnosticVirtualLinesInfo',
  [vim.diagnostic.severity.HINT] = 'DiagnosticVirtualLinesHint',
}

-- Returns the line number (0-indexed) of the current cursor position.
---@return integer
local function current_lnum()
  return vim.api.nvim_win_get_cursor(0)[1] - 1 -- row is 1-indexed
end

---@param diagnostic vim.Diagnostic
---@return string
local function format_message(diagnostic)
  local message = diagnostic.message
  if diagnostic.source then
    message = diagnostic.source .. ': ' .. message
  end
  if diagnostic.code then
    message = ('%s [%s]'):format(message, diagnostic.code)
  end
  return message
end

-- Some characters (like tabs) take up more than one cell. Additionally, inline virtual text can
-- make the distance between 2 columns larger. A diagnostic aligned under such characters needs to
-- account for that and that many spaces to its left.
---@param bufnr integer
---@param lnum integer
---@param start_col integer
---@param end_col integer
---@return integer
local function distance_between_columns(bufnr, lnum, start_col, end_col)
  return vim.api.nvim_buf_call(bufnr, function()
    local start_virtcol = vim.fn.virtcol { lnum + 1, start_col }
    local end_virtcol = vim.fn.virtcol { lnum + 1, end_col + 1 }
    return end_virtcol - 1 - start_virtcol
  end)
end

-- Render the diagnostics that are on the current line as virtual lines.
--
-- This is a simpler version of what's in [Neovim core](https://github.com/neovim/neovim/blob/f5714994bc4fc578b5f07bca403e7067e6d9b5a0/runtime/lua/vim/diagnostic.lua#L1721).
--
-- Returns the line number for which the virtual lines were rendered, `nil` if there are no
-- diagnostics on that line.
---@return integer|nil
local function render_virtual_lines()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = current_lnum()
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  if vim.tbl_isempty(diagnostics) then
    return
  end

  -- Sort the diagnostics in ascending order of column (left to right).
  table.sort(diagnostics, function(d1, d2)
    return d1.col < d2.col
  end)

  -- This stack is a list of two-element tables.
  ---@type { kind: ElementKind, data: string | vim.diagnostic.Severity | vim.Diagnostic }[]
  local stack = {}

  local first = true
  local previous_col = 0

  for _, diagnostic in ipairs(diagnostics) do
    if first then
      -- Insert spaces to align the first diagnostic, if needed.
      table.insert(stack, {
        kind = ElementKind.Space,
        data = string.rep(' ', distance_between_columns(bufnr, diagnostic.lnum, 0, diagnostic.col)),
      })
      first = false
    elseif diagnostic.col ~= previous_col then
      table.insert(stack, {
        kind = ElementKind.Space,
        data = string.rep(
          ' ',
          -- +1 because indexing starts at 0 in one API but at 1 in the other.
          distance_between_columns(bufnr, diagnostic.lnum, previous_col + 1, diagnostic.col)
        ),
      })
    else
      table.insert(stack, { kind = ElementKind.Overlap, data = diagnostic.severity })
    end

    if diagnostic.message:find '^%s*$' then
      -- How is this being used?
      table.insert(stack, { kind = ElementKind.Blank, data = diagnostic })
    else
      table.insert(stack, { kind = ElementKind.Diagnostic, data = diagnostic })
    end

    previous_col = diagnostic.col
  end

  local chars = {
    cross = '┼',
    horizontal = '─',
    horizontal_up = '┴',
    up_right = '└',
    vertical = '│',
    vertical_right = '├',
  }

  local virt_lines = {}

  -- Note that we read in the order opposite to insertion.
  for i = #stack, 1, -1 do
    if stack[i].kind == ElementKind.Diagnostic then
      local diagnostic = stack[i].data
      local left = {} ---@type {[1]:string, [2]:string}
      local overlap = false

      -- Iterate the stack for this line to find elements on the left.
      for j = 1, i - 1 do
        local type = stack[j].kind
        local data = stack[j].data
        if type == ElementKind.Space then
          table.insert(left, { data, '' })
        elseif type == ElementKind.Diagnostic then
          -- If an overlap follows this line, don't add an extra column.
          if stack[j + 1].kind ~= ElementKind.Overlap then
            table.insert(left, { chars.vertical, 'Grey' })
          end
          overlap = false
        elseif type == ElementKind.Blank then
          table.insert(left, { chars.up_right, 'Grey' })
        elseif type == ElementKind.Overlap then
          overlap = true
        end
      end

      ---@type string
      local center_char
      if overlap then
        center_char = chars.vertical_right
      else
        center_char = chars.up_right
      end
      local center = {
        {
          string.format('%s%s', center_char, string.rep(chars.horizontal, 4) .. ' '),
          'Grey',
        },
      }

      -- We can draw on the left side if and only if:
      -- a. Is the last one stacked this line.
      -- b. Has enough space on the left.
      -- c. Is just one line.
      -- d. Is not an overlap.
      ---@cast diagnostic vim.Diagnostic
      for msg_line in format_message(diagnostic):gmatch '([^\n]+)' do
        local vline = {}
        vim.list_extend(vline, left)
        vim.list_extend(vline, center)
        vim.list_extend(vline, { { msg_line, highlight_map[diagnostic.severity] } })

        table.insert(virt_lines, vline)

        -- Special-case for continuation lines:
        if overlap then
          center = {
            { chars.vertical, 'Grey' },
            { '     ', '' },
          }
        else
          center = { { '      ', '' } }
        end
      end
    end
  end

  vim.api.nvim_buf_set_extmark(bufnr, namespace, lnum, 0, { virt_lines = virt_lines })
  return lnum
end

-- Setup the auto-rendering of virtual line diagnostics when the cursor is on a line with
-- diagnostics.
function M.setup_auto_virtual_lines()
  local group = vim.api.nvim_create_augroup('dm__virtual_line_diagnostics', { clear = true })

  -- The line number for which the virtual lines were rendered, `nil` if there are no diagnostics on
  -- that line or if the diagnostics were cleared.
  ---@type integer|nil
  local lnum

  -- Keep track of the changedtick to re-render whenever the buffer changes.
  ---@type integer
  local changedtick = vim.b.changedtick

  -- Returns the number of git conflicts in the current buffer.
  local git_conflict_count = require('git-conflict').conflict_count

  vim.api.nvim_create_autocmd('CursorHold', {
    group = group,
    callback = function()
      if vim.bo.filetype == 'lazy' or git_conflict_count() > 0 then
        return
      end
      if lnum and lnum == current_lnum() and changedtick == vim.b.changedtick then
        -- No need to re-render if the cursor is still on the same line.
        return
      end
      changedtick = vim.b.changedtick
      lnum = render_virtual_lines()
    end,
    desc = 'Render virtual line diagnostics for the current line',
  })

  vim.api.nvim_create_autocmd('CursorMoved', {
    group = group,
    callback = function()
      if lnum then
        if lnum == current_lnum() then
          -- No need to clear if the cursor is still on the same line.
          return
        end
        vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
        lnum = nil
      end
    end,
    desc = 'Clear virtual line diagnostics when moving the cursor',
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = group,
    callback = function()
      if lnum then
        vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
        lnum = nil
      end
    end,
    desc = 'Clear virtual line diagnostics when entering insert mode',
  })
end

return M
