local vdiagnostic = vim.diagnostic
local lint = require "dm.linter.lint"

local register = lint.register

do
  local pat = "[^:]+:(%d+):(%d+):(([EWF])%w+):(.+)"
  local group = { "lnum", "col", "code", "severity", "message" }

  local severity_map = {
    E = vdiagnostic.severity.ERROR,
    W = vdiagnostic.severity.WARN,
    F = vdiagnostic.severity.WARN,
  }

  register("python", {
    cmd = "flake8",
    args = { "--format", "%(path)s:%(row)d:%(col)d:%(code)s:%(text)s", "-" },
    ignore_exitcode = true,
    parser = function(output)
      local diagnostics = {}
      for line in vim.gsplit(output, "\n") do
        local diagnostic = vdiagnostic.match(line, pat, group, severity_map)
        if diagnostic then
          diagnostic.source = "flake8"
          table.insert(diagnostics, diagnostic)
        end
      end
      return diagnostics
    end,
  })
end

do
  local pat = "([^:]+):(%d+):(%d+): (%a+): (.*)"
  local groups = { "file", "lnum", "col", "severity", "message" }

  local severity_map = {
    error = vdiagnostic.severity.ERROR,
    warning = vdiagnostic.severity.WARN,
    note = vdiagnostic.severity.HINT,
  }

  register("python", {
    cmd = "mypy",
    args = {
      "--ignore-missing-imports",
      "--show-column-numbers",
      "--hide-error-codes",
      "--hide-error-context",
      "--no-color-output",
      "--no-error-summary",
      "--no-pretty",
    },
    stdin = false,
    ignore_exitcode = true,
    parser = function(output, bufnr)
      local diagnostics = {}
      for line in vim.gsplit(output, "\n") do
        local diagnostic = vdiagnostic.match(line, pat, groups, severity_map)
        if
          diagnostic
          -- Use the `file` group to filter diagnostics related to other files.
          -- This is done because `mypy` can follow imports and report errors
          -- from other files which will be displayed in the current buffer.
          and diagnostic.file
            == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
        then
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
      for _, item in ipairs(vim.json.decode(output)) do
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

do
  local severity_map = {
    error = vdiagnostic.severity.ERROR,
    warning = vdiagnostic.severity.WARN,
    info = vdiagnostic.severity.INFO,
    style = vdiagnostic.severity.HINT,
  }

  register("Dockerfile", {
    cmd = "hadolint",
    args = { "--format", "json", "-" },
    ignore_exitcode = true,
    parser = function(output)
      local diagnostics = {}
      for _, item in ipairs(vim.json.decode(output)) do
        table.insert(diagnostics, {
          source = "hadolint",
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

return { lint = lint.lint }
