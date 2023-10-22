return {
  cmd = 'actionlint',
  args = { '-no-color', '-format', '{{json .}}' },
  ignore_exitcode = true,
  enable = function(bufnr)
    -- Enable it only for GitHub Actions workflow files.
    return vim.api.nvim_buf_get_name(bufnr):match '^.*%.github/workflows/.*$' ~= nil
  end,
  parser = function(output)
    local diagnostics = {}
    for _, item in ipairs(vim.json.decode(output)) do
      table.insert(diagnostics, {
        source = 'actionlint',
        lnum = item.line - 1,
        end_lnum = item.line,
        col = item.column - 1,
        end_col = item.column,
        severity = vim.diagnostic.severity.ERROR,
        code = item.kind,
        message = item.message,
      })
    end
    return diagnostics
  end,
}
