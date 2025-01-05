local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  style = vim.diagnostic.severity.HINT,
}

---@type LinterConfig
return {
  cmd = 'hadolint',
  args = { '--format', 'json' },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    for _, item in ipairs(vim.json.decode(output)) do
      table.insert(diagnostics, {
        source = 'hadolint',
        lnum = item.line - 1,
        end_lnum = item.line,
        col = item.column - 1,
        end_col = item.column,
        severity = severity_map[item.level],
        code = item.code,
        message = item.message,
      })
    end
    return diagnostics
  end,
}
