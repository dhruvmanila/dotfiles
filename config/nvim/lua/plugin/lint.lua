local lint = require('lint')

local MYPY_PATTERN  = "[^:]+:(%d+):(%d+): (%a+): (.*)"
local FLAKE8_PATTERN = "[^:]+:(%d+):(%d+): (%w+) (.*)"

local function split(str, sep)
  sep = sep or "%s"
  local result = {}
  for v in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(result, v)
  end
  return result
end

local function parse_mypy_output(output, _)
  local result = split(output, "\n")
  -- Remove the last 'found n errors in n file ...' message
  table.remove(result)
  local diagnostics = {}
  local lineno, offset, severity, msg, errno

  for _, message in ipairs(result) do
    lineno, offset, severity, msg = string.match(message, MYPY_PATTERN)
    lineno = tonumber(lineno or 1) - 1
    offset = tonumber(offset or 1) - 1
    errno = 2
    if severity == 'error' then errno = 1 end
    table.insert(diagnostics, {
      source = 'mypy',
      range = {
        ['start'] = {
          line = lineno,
          character = offset
        },
        ['end'] = {
          line = lineno,
          character = offset + 1
        }
      },
      message = msg,
      severity = errno,
    })
  end
  return diagnostics
end

local function parse_flake8_output(output, _)
  local result = split(output, '\n')
  local diagnostics = {}
  local lineno, offset, code, msg

  for _, message in ipairs(result) do
    lineno, offset, code, msg = string.match(message, FLAKE8_PATTERN)
    lineno = tonumber(lineno or 1) - 1
    offset = tonumber(offset or 1) - 1
    table.insert(diagnostics, {
      source = 'flake8',
      code = code,
      range = {
        ['start'] = {
          line = lineno,
          character = offset
        },
        ['end'] = {
          line = lineno,
          character = offset + 1
        }
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
    args = {
      '--ignore-missing-imports',
      '--show-column-numbers',
      '--follow-imports',
      'silent'
    },
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
