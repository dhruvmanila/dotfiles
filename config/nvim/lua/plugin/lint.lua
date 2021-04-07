local lint = require('lint')

local FLAKE8_PATTERN = "[^:]+:(%d+):(%d+): (%w+) (.*)"

local function parse_flake8_output(output, _)
  local result = vim.fn.split(output, "\n")
  local diagnostics = {}

  for _, message in ipairs(result) do
    local lineno, offset, code, msg = string.match(message, FLAKE8_PATTERN)
    lineno = tonumber(lineno or 1) - 1
    offset = tonumber(offset or 1) - 1
    table.insert(diagnostics, {
      source = 'flake8',
      code = code,
      range = {
        ['start'] = {line = lineno, character = offset},
        ['end'] = {line = lineno, character = offset + 1}
      },
      message = code .. ' ' .. msg,
      severity = vim.lsp.protocol.DiagnosticSeverity.Error,
    })
  end
  return diagnostics
end


lint.linters.flake8 = {
  cmd = 'flake8',
  stdin = true,
  args = {'-'},
  parser = parse_flake8_output,
}

lint.linters_by_ft = {
  python = {'flake8'}
}
