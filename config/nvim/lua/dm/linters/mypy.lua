local pattern = '([^:]+):(%d+):(%d+): (%a+): (.*)'
local groups = { 'file', 'lnum', 'col', 'severity', 'message' }

local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.HINT,
}

return {
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
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local current_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.')

    for line in vim.gsplit(output, '\n') do
      local diagnostic = vim.diagnostic.match(line, pattern, groups, severity_map)
      -- Use the `file` group to filter diagnostics related to other files.
      -- This is done because `mypy` can follow imports and report errors
      -- from other files which will be displayed in the current buffer.
      if diagnostic and diagnostic.file == current_file then
        diagnostic.source = 'mypy'
        if
          diagnostic.severity == vim.diagnostic.severity.HINT
          and #diagnostics > 0
          and diagnostics[#diagnostics].lnum == diagnostic.lnum
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
}
