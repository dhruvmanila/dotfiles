local lint = require 'dm.linter.lint'

local register = lint.register

-- Dockerfile:hadolint {{{1
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

-- go:golangci-lint {{{1

do
  local config_path

  local severity_map = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    refactor = vim.diagnostic.severity.INFO,
    convention = vim.diagnostic.severity.HINT,
  }

  register('go', {
    cmd = 'golangci-lint',
    args = function(bufnr)
      return {
        'run',
        '--out-format',
        'json',
        '--config',
        config_path,
        -- Path to the package directory.
        vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
      }
    end,
    -- Enable the linter only if there's a config file in the project.
    enable = function(bufnr)
      config_path = vim.fs.find({
        -- https://golangci-lint.run/usage/configuration/#config-file
        '.golangci.yml',
        '.golangci.yaml',
        '.golangci.toml',
        '.golangci.json',
      }, {
        path = vim.api.nvim_buf_get_name(bufnr),
        upward = true,
        type = 'file',
      })[1]
      return config_path ~= nil
    end,
    stdin = false,
    append_fname = false,
    ignore_exitcode = true,
    parser = function(output, bufnr)
      if output == '' then
        return {}
      end

      local decoded = vim.json.decode(output)
      if decoded.Issues == nil then
        return {}
      end

      local diagnostics = {}
      -- Current file path from the current working directory.
      local current_file =
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.')

      for _, item in ipairs(decoded.Issues) do
        -- Publish diagnostics only for the current file.
        if item.Pos.Filename == current_file then
          local lnum = math.max(item.Pos.Line - 1, 0)
          local col = math.max(item.Pos.Column - 1, 0)
          table.insert(diagnostics, {
            lnum = lnum,
            end_lnum = lnum,
            col = col,
            end_col = col,
            severity = severity_map[item.Severity] or severity_map.warning,
            source = item.FromLinter,
            message = item.Text,
          })
        end
      end
      return diagnostics
    end,
  })
end

-- python:flake8 {{{1
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
    enable = function()
      -- Let's just use `ruff`
      return false
    end,
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

-- python:mypy {{{1
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
      local current_file =
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.')

      for line in vim.gsplit(output, '\n') do
        local diagnostic = vim.diagnostic.match(line, pat, groups, severity_map)
        -- Use the `file` group to filter diagnostics related to other files.
        -- This is done because `mypy` can follow imports and report errors
        -- from other files which will be displayed in the current buffer.
        if diagnostic and diagnostic.file == current_file then
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

-- python:ruff {{{1

register('python', {
  cmd = 'ruff',
  args = { 'check', '--exit-zero', '--format', 'json' },
  stdin = false,
  parser = function(output)
    local diagnostics = {}
    for _, item in ipairs(vim.json.decode(output)) do
      -- Ignore all the fixed diagnostics. This will be true if a fix was
      -- available and the `--fix` flag was passed.
      if not item.fixed then
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
    end
    return diagnostics
  end,
})

-- yaml:actionlint {{{1
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

-- }}}1

return { lint = lint.lint }
