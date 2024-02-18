local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
local groups = { 'lnum', 'col', 'code', 'message' }

return {
  cmd = 'flake8',
  args = function(bufnr)
    return {
      '--format',
      '%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
      '--no-show-source',
      '--stdin-display-name',
      vim.api.nvim_buf_get_name(bufnr),
      '--extend-ignore',
      'E501', -- line too long
    }
  end,
  ignore_exitcode = true,
  enable = function(bufnr)
    -- Enable only for files in the playground directory.
    return vim.startswith(vim.api.nvim_buf_get_name(bufnr), vim.g.os_homedir .. '/playground')
  end,
  parser = function(output)
    local diagnostics = {}
    for line in vim.gsplit(output, '\n') do
      local diagnostic = vim.diagnostic.match(line, pattern, groups, nil, {
        source = 'flake8',
        severity = vim.diagnostic.severity.WARN,
      })
      if diagnostic then
        table.insert(diagnostics, diagnostic)
      end
    end
    return diagnostics
  end,
}
