local lint = require('lint')

local MYPY_PATTERN  = "([^:]+):(%d+):(%d+): (%a+): (.*)"
local FLAKE8_PATTERN = "[^:]+:(%d+):(%d+): (%w+) (.*)"

local function split(str, sep)
  sep = sep or "%s"
  local result = {}
  for v in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(result, v)
  end
  return result
end

local function parse_mypy_output(output, bufnr)
  local result = split(output, "\n")
  -- Remove the last 'found n errors in n file ...' message
  table.remove(result)
  local diagnostics = {}
  local buf_file = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':~:.')

  for _, message in ipairs(result) do
    local file, lineno, offset, severity, msg = string.match(message, MYPY_PATTERN)
    -- We should only report the errors found in the current file
    -- In `mypy` this can be avoided directly by passing `--follow-imports silent`
    -- flag but we should handle it in here.
    if file == buf_file then
      lineno = tonumber(lineno or 1) - 1
      offset = tonumber(offset or 1) - 1

      local errno = 1
      if severity == 'warning' then
        errno = 2
      elseif severity == 'note' then
        errno = 4
      end

      table.insert(diagnostics, {
        source = 'mypy',
        range = {
          ['start'] = {line = lineno, character = offset},
          ['end'] = {line = lineno, character = offset + 1}
        },
        message = msg,
        severity = errno,
      })
    end
  end
  return diagnostics
end

local function parse_flake8_output(output, _)
  local result = split(output, '\n')
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
      severity = 1
    })
  end
  return diagnostics
end


lint.linters = {
  mypy = {
    cmd = 'mypy',
    stdin = false,
    args = {'--ignore-missing-imports', '--show-column-numbers'},
    stream = 'stdout',
    parser = parse_mypy_output,
  },
  flake8 = {
    cmd = 'flake8',
    stdin = false,
    args = {},
    stream = 'stdout',
    parser = parse_flake8_output,
  }
}

lint.linters_by_ft = {
  python = {'mypy', 'flake8'}
}
