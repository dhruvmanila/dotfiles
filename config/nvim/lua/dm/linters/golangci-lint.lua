---@type string?
local config_path

local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

---@type LinterConfig
return {
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
  ignore_exitcode = true,
  -- Enable the linter only if there's a config file in the project.
  enable = function(bufnr)
    config_path = vim.fs.find({
      -- https://golangci-lint.run/usage/configuration/#config-file
      '.golangci.yml',
      '.golangci.yaml',
      '.golangci.toml',
      '.golangci.json',
    }, {
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
      upward = true,
      type = 'file',
      stop = dm.OS_HOMEDIR,
    })[1]
    return config_path ~= nil
  end,
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
    local current_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.')

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
}
