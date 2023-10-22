return {
  cmd = 'sqlfluff',
  args = {
    'lint',
    '--disable-progress-bar',
    '--nocolor',
    '--nofail',
    '--format=json',
    '--dialect=postgres',
  },
  parser = function(output)
    local diagnostics = {}
    for _, item in ipairs(vim.json.decode(output)) do
      for _, violation in ipairs(item.violations) do
        table.insert(diagnostics, {
          source = 'sqlfluff',
          lnum = violation.line_no - 1,
          end_lnum = violation.line_no,
          col = violation.line_pos - 1,
          end_col = violation.line_pos,
          severity = vim.diagnostic.severity.WARN,
          code = violation.code,
          message = violation.description,
        })
      end
    end
    return diagnostics
  end,
}
