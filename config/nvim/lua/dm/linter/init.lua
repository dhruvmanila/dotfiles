local lint = require 'dm.linter.lint'

local register = lint.register

do
  local pat = '[^:]+:(%d+):(%d+):(([EWF])%w+):(.+)'
  local group = { 'lnum', 'col', 'code', 'severity', 'message' }

  local severity_map = {
    E = vim.diagnostic.severity.ERROR,
    W = vim.diagnostic.severity.WARN,
    F = vim.diagnostic.severity.WARN,
  }

  register('python', {
    cmd = 'flake8',
    args = {
      '--format',
      '%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
      '--extend-ignore',
      'E501', -- line too long
      '-',
    },
    ignore_exitcode = true,
    parser = function(output)
      local diagnostics = {}
      for line in vim.gsplit(output, '\n') do
        local diagnostic = vim.diagnostic.match(line, pat, group, severity_map)
        if diagnostic then
          diagnostic.source = 'flake8'
          table.insert(diagnostics, diagnostic)
        end
      end
      return diagnostics
    end,
  })
end

do
  local pat = '([^:]+):(%d+):(%d+): (%a+): (.*)'
  local groups = { 'file', 'lnum', 'col', 'severity', 'message' }

  local severity_map = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    note = vim.diagnostic.severity.HINT,
  }

  register('python', {
    cmd = 'mypy',
    args = {
      '--ignore-missing-imports',
      '--show-column-numbers',
      '--hide-error-codes',
      '--hide-error-context',
      '--no-color-output',
      '--no-error-summary',
      '--no-pretty',
    },
    stdin = false,
    ignore_exitcode = true,
    parser = function(output, bufnr)
      local diagnostics = {}
      for line in vim.gsplit(output, '\n') do
        local diagnostic = vim.diagnostic.match(line, pat, groups, severity_map)
        if
          diagnostic
          -- Use the `file` group to filter diagnostics related to other files.
          -- This is done because `mypy` can follow imports and report errors
          -- from other files which will be displayed in the current buffer.
          and diagnostic.file
            == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':~:.')
        then
          diagnostic.source = 'mypy'
          if
            diagnostic.severity == vim.diagnostic.severity.HINT
            and #diagnostics > 0
          then
            diagnostics[#diagnostics].message = diagnostics[#diagnostics].message
              .. '\n'
              .. diagnostic.message
          else
            table.insert(diagnostics, diagnostic)
          end
        end
      end
      return diagnostics
    end,
  })
end

do
  local severity_map = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    info = vim.diagnostic.severity.INFO,
    style = vim.diagnostic.severity.HINT,
  }

  register('Dockerfile', {
    cmd = 'hadolint',
    args = { '--format', 'json', '-' },
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
  })
end

register('yaml', {
  cmd = 'actionlint',
  args = { '-no-color', '-format', '{{json .}}', '-' },
  ignore_exitcode = true,
  enable = function(bufnr)
    -- Enable it only for GitHub workflow files.
    return vim.api.nvim_buf_get_name(bufnr):match '^.*%.github/workflows/.*$'
      ~= nil
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
})

return { lint = lint.lint }
