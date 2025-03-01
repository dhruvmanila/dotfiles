-- Format: `file:lnum:col:end_lnum:end_col: severity: message`
local pattern = '([^:]+):(%d+):(%d+):(%d+):(%d+): (%a+): (.*)'
-- Format: `file:lnum:col:end_lnum:end_col: severity: message [code]`
local pattern_with_code = pattern .. ' %[(%a[%a-]+)%]'

-- Groups corresponding to the capture groups in the above pattern.
local groups = { 'file', 'lnum', 'col', 'end_lnum', 'end_col', 'severity', 'message', 'code' }

-- Map of `mypy` severities to `vim.diagnostic.severity` levels.
local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.HINT,
}

---@class MypyDiagnostic: vim.Diagnostic
---@field file string

-- Parse a line from the output of `mypy`.
---@param line string
---@return MypyDiagnostic?
local function parse_line(line)
  local diagnostic = vim.diagnostic.match(line, pattern_with_code, groups, severity_map)
  if not diagnostic then
    diagnostic = vim.diagnostic.match(line, pattern, groups, severity_map)
  end
  ---@cast diagnostic MypyDiagnostic?
  return diagnostic
end

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
      local diagnostic = parse_line(line)
      if diagnostic and diagnostic.file == current_file then
        diagnostic.source = 'mypy'
        -- For hints, try to check if they need to be appended to the previous diagnostic.
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
