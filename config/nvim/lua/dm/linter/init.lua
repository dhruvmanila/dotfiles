local vdiagnostic = vim.diagnostic
local lint = require "dm.linter.lint"

local register = lint.register

do
  local pattern = "[^:]+:(%d+):(%d+):(%w+):(.+)"
  local group = { "lnum", "col", "code", "message" }

  local severity_map = {
    E = vdiagnostic.severity.ERROR,
    W = vdiagnostic.severity.WARN,
  }

  register("python", {
    cmd = "flake8",
    args = { "--format", "%(path)s:%(row)d:%(col)d:%(code)s:%(text)s", "-" },
    ignore_exitcode = true,
    parser = function(output)
      local diagnostics = {}
      for line in vim.gsplit(output, "\n") do
        if line ~= "" then
          local diagnostic = vdiagnostic.match(line, pattern, group)
          diagnostic.source = "flake8"
          diagnostic.severity = severity_map[diagnostic.code:sub(1, 1)]
            or severity_map.W
          table.insert(diagnostics, diagnostic)
        end
      end
      return diagnostics
    end,
  })
end

do
  local pattern = "[^:]+:(%d+):(%d+): (%a+): (.*)"
  local groups = { "lnum", "col", "severity", "message" }

  local severity_map = {
    error = vdiagnostic.severity.ERROR,
    warning = vdiagnostic.severity.WARN,
    note = vdiagnostic.severity.HINT,
  }

  register("python", {
    cmd = "mypy",
    args = {
      "--show-column-numbers",
      "--hide-error-context",
      "--no-color-output",
      "--no-error-summary",
    },
    stdin = false,
    ignore_exitcode = true,
    parser = function(output)
      local diagnostics = {}
      for line in vim.gsplit(output, "\n") do
        if line ~= "" then
          local diagnostic = vdiagnostic.match(
            line,
            pattern,
            groups,
            severity_map
          )
          diagnostic.source = "mypy"
          table.insert(diagnostics, diagnostic)
        end
      end
      return diagnostics
    end,
  })
end

do
  local severity_map = {
    error = vdiagnostic.severity.ERROR,
    warning = vdiagnostic.severity.WARN,
    note = vdiagnostic.severity.INFO,
    style = vdiagnostic.severity.HINT,
  }

  register("sh", {
    cmd = "shellcheck",
    args = function()
      -- Or should we just hardcode the default shell?
      local shell = vim.fn.fnamemodify(vim.env.SHELL, ":t")
      return { "--format", "json", "--shell", shell, "-" }
    end,
    ignore_exitcode = true,
    parser = function(output)
      local diagnostics = {}
      for _, item in ipairs(vim.fn.json_decode(output)) do
        table.insert(diagnostics, {
          source = "shellcheck",
          lnum = item.line - 1,
          end_lnum = item.endLine - 1,
          col = item.column - 1,
          end_col = item.endColumn - 1,
          severity = severity_map[item.level],
          code = item.code,
          message = item.message,
        })
      end
      return diagnostics
    end,
  })
end

return { lint = lint.lint }
