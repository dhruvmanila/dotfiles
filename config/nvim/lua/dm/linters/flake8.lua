local pattern = '[^:]+:(%d+):(%d+):(([EWF])%w+):(.+)'
local groups = { 'lnum', 'col', 'code', 'severity', 'message' }

local severity_map = {
  E = vim.diagnostic.severity.ERROR,
  W = vim.diagnostic.severity.WARN,
  F = vim.diagnostic.severity.WARN,
}

return {
  cmd = 'flake8',
  args = {
    '--format',
    '%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
    '--extend-ignore',
    'E501', -- line too long
  },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    for line in vim.gsplit(output, '\n') do
      local diagnostic = vim.diagnostic.match(line, pattern, groups, severity_map)
      if diagnostic then
        diagnostic.source = 'flake8'
        table.insert(diagnostics, diagnostic)
      end
    end
    return diagnostics
  end,
}
