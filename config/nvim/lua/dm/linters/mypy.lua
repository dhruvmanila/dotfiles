local pattern = '([^:]+):(%d+):(%d+):(%d+):(%d+): (%a+): (.*) %[(%a[%a-]+)%]'
local groups = { 'file', 'lnum', 'col', 'end_lnum', 'end_col', 'severity', 'message', 'code' }

local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.HINT,
}

---@type LinterConfig
return {
  cmd = 'mypy',
  args = function()
    local args = {
      '--ignore-missing-imports',
      '--show-column-numbers',
      '--show-error-end',
      '--hide-error-context',
      '--no-color-output',
      '--no-error-summary',
      '--no-pretty',
    }
    local venv_dir = vim.fs.joinpath(dm.CWD, '.venv')
    if dm.path_exists(venv_dir) then
      vim.list_extend(args, {
        '--python-executable',
        vim.fs.joinpath(venv_dir, 'bin', 'python'),
      })
    end
    return args
  end,
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
        if diagnostic.severity == vim.diagnostic.severity.HINT and #diagnostics > 0 then
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
