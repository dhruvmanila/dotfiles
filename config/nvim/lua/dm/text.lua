-- Inspired from @folke's trouble.nvim plugin with some enhancements.
-- https://github.com/folke/trouble.nvim/blob/main/lua/trouble/view/text.lua
--
-- This is currently being used for:
--   - Dashboard

local ns = vim.api.nvim_create_namespace 'dm.dashboard'

---@class Text
local Text = {}
Text.__index = Text

-- Initiate the `Text` object for the provided bufnr. If bufnr is not provided,
-- the current bufnr will be assumed.
--
-- This object helps in rendering text on a buffer. Individual parts of a single
-- line can be highlighted in different color using `add` method and blocks of
-- text can be added with the same highlight using `block` method.
--
-- Both method takes an optional `newline` argument which adds a newline, thus
-- moving the internal state on the next line.
--
---@param bufnr? number
---@return Text
function Text:new(bufnr)
  return setmetatable({
    bufnr = bufnr or vim.api.nvim_get_current_buf(),
    longest_line = 0,
    line = 0,
    current = '',
    linehl = {},
  }, self)
end

-- Add the given `text` with an optional `hl_group`.
---@param text string
---@param hl_group? string
---@param newline? boolean
function Text:add(text, hl_group, newline)
  if hl_group then
    local from = string.len(self.current)
    table.insert(self.linehl, {
      from = from,
      to = from + string.len(text),
      hl_group = hl_group,
    })
  end
  self.current = self.current .. text
  if newline then
    self:newline()
  end
end

-- Add a block of text with an optional `hl_group`.
---@param block string[]
---@param hl_group? string
function Text:block(block, hl_group, newline)
  assert(self.current == '', 'cannot add block while in between a line')
  for _, line in ipairs(block) do
    self.current = line
    if hl_group then
      table.insert(self.linehl, {
        from = 0,
        to = -1,
        hl_group = hl_group,
      })
    end
    self:newline()
  end
  if newline then
    self:newline()
  end
end

-- Move to the next line after rendering the current line. This will also keep
-- track of the current longest line.
function Text:newline()
  self:_render()
  self.longest_line = math.max(self.longest_line, string.len(self.current))
  self.line = self.line + 1
  self.current = ''
  self.linehl = {}
end

-- Render the current internal state.
function Text:_render()
  vim.api.nvim_buf_set_lines(self.bufnr, self.line, self.line, false, { self.current })
  for _, data in ipairs(self.linehl) do
    vim.hl.range(self.bufnr, ns, data.hl_group, { self.line, data.from }, { self.line, data.to })
  end
  -- For the zeroth line, a newline is added at the end, so remove it.
  if self.line == 0 then
    vim.api.nvim_buf_set_lines(self.bufnr, -2, -1, false, {})
  end
end

return Text
