local severity_map = {
  ['F821'] = vim.diagnostic.severity.ERROR,
  ['E902'] = vim.diagnostic.severity.ERROR,
  ['E999'] = vim.diagnostic.severity.ERROR,
  [vim.NIL] = vim.diagnostic.severity.ERROR,
}

---@generic T
---@param value T|vim.NIL
---@return T|nil
local function code(value)
  if value == vim.NIL then
    return nil
  end
  return value
end

return {
  cmd = 'ruff',
  args = {
    'check',
    '--exit-zero',
    '--no-cache',
    '--force-exclude',
    '--output-format',
    'json',
  },
  parser = function(output)
    local diagnostics = {}
    for _, item in ipairs(vim.json.decode(output)) do
      table.insert(diagnostics, {
        source = 'ruff',
        lnum = math.max(item.location.row - 1, 0),
        end_lnum = math.max(item.end_location.row - 1, 0),
        col = math.max(item.location.column - 1, 0),
        end_col = math.max(item.end_location.column - 1, 0),
        severity = severity_map[item.code] or vim.diagnostic.severity.WARN,
        code = code(item.code),
        message = item.message,
      })
    end
    return diagnostics
  end,
}
