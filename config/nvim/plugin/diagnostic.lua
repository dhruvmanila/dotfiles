local icons = dm.icons
local keymap = vim.keymap

-- Icon and highlight information for each diagnostic severity.
---@type { icon: string, hl: string }[]
local severity_info = {
  { icon = icons.error, hl = 'DiagnosticSignError' },
  { icon = icons.warn, hl = 'DiagnosticSignWarn' },
  { icon = icons.info, hl = 'DiagnosticSignInfo' },
  { icon = icons.hint, hl = 'DiagnosticSignHint' },
}

for _, info in ipairs(severity_info) do
  vim.fn.sign_define(info.hl, { text = info.icon, texthl = info.hl })
end

-- Prefix each diagnostic in the floating window with an appropriate icon.
---@param diagnostic table
---@return string #icon as per the diagnostic severity
---@return string #highlight group as per the diagnostic severity
local function prefix_diagnostic(diagnostic)
  local info = severity_info[diagnostic.severity]
  return info.icon .. ' ', info.hl
end

-- Global diagnostic configuration.
vim.diagnostic.config {
  underline = false,
  virtual_text = false,
  signs = true,
  severity_sort = true,
  float = {
    header = false,
    source = 'always',
    prefix = prefix_diagnostic,
  },
}

-- For all types of diagnostics: `[d`, `]d`
keymap.set('n', '[d', function()
  vim.diagnostic.goto_prev {
    float = { focusable = false },
  }
end, { desc = 'Diagnostic: Goto prev' })
keymap.set('n', ']d', function()
  vim.diagnostic.goto_next {
    float = { focusable = false },
  }
end, { desc = 'Diagnostic: Goto next' })

-- For warning and error diagnostics: `[w`, `]w`
keymap.set('n', '[w', function()
  vim.diagnostic.goto_prev {
    float = { focusable = false },
    severity = { min = vim.diagnostic.severity.WARN },
  }
end, { desc = 'Diagnostic: Goto prev (warning/error)' })
keymap.set('n', ']w', function()
  vim.diagnostic.goto_next {
    float = { focusable = false },
    severity = { min = vim.diagnostic.severity.WARN },
  }
end, { desc = 'Diagnostic: Goto next (warning/error)' })

keymap.set('n', '<leader>l', function()
  vim.diagnostic.open_float { scope = 'line' }
end, { desc = 'Show line diagnostics' })
