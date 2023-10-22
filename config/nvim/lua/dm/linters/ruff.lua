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
        severity = vim.diagnostic.severity.WARN,
        code = item.code,
        message = item.message,
      })
    end
    return diagnostics
  end,
}
