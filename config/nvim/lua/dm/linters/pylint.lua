local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  fatal = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  info = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

---@type LinterConfig
return {
  cmd = 'pylint',
  args = { '--output-format', 'json' },
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local current_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.')

    for _, item in ipairs(vim.json.decode(output)) do
      if not item.path or item.path == current_file then
        local column = item.column > 0 and item.column or 0
        local end_column = item.endColumn ~= vim.NIL and item.endColumn or column
        table.insert(diagnostics, {
          source = 'pylint',
          lnum = item.line - 1,
          col = column,
          end_lnum = item.line - 1,
          end_col = end_column,
          severity = assert(severity_map[item.type], 'missing mapping for severity ' .. item.type),
          message = ('%s (%s)'):format(item.message, item.symbol),
          code = item['message-id'],
        })
      end
    end
    return diagnostics
  end,
}
