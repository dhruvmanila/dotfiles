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

-- Global diagnostic configuration.
vim.diagnostic.config {
  underline = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.error,
      [vim.diagnostic.severity.WARN] = icons.warn,
      [vim.diagnostic.severity.INFO] = icons.info,
      [vim.diagnostic.severity.HINT] = icons.hint,
    },
  },
  float = {
    header = '',
    source = true,
    prefix = function(diagnostic)
      local info = severity_info[diagnostic.severity]
      return info.icon .. ' ', info.hl
    end,
  },
  jump = {
    float = {
      focusable = false,
      scope = 'cursor',
    },
  },
}

-- For all types of diagnostics: `[d`, `]d`
keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -vim.v.count1 }
  dm.center_cursor()
end, { desc = 'Diagnostic: Goto prev' })

keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = vim.v.count1 }
  dm.center_cursor()
end, { desc = 'Diagnostic: Goto next' })

-- For warning and error diagnostics: `[w`, `]w`
keymap.set('n', '[w', function()
  vim.diagnostic.jump {
    count = -vim.v.count1,
    severity = { min = vim.diagnostic.severity.WARN },
  }
  dm.center_cursor()
end, { desc = 'Diagnostic: Goto prev (warning/error)' })

keymap.set('n', ']w', function()
  vim.diagnostic.jump {
    count = vim.v.count1,
    severity = { min = vim.diagnostic.severity.WARN },
  }
  dm.center_cursor()
end, { desc = 'Diagnostic: Goto next (warning/error)' })

keymap.set('n', '<leader>l', function()
  vim.diagnostic.open_float { scope = 'line' }
end, { desc = 'Show line diagnostics' })

keymap.set('n', '<leader>dt', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })
