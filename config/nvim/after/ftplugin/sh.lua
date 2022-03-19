---@type number
local namespace = vim.api.nvim_get_namespaces()['dm__diagnostics_sh_shellcheck']

-- Return a list of diagnostic codes of the current buffer for shellcheck.
---@return string[]
local function buf_shellcheck_error_codes()
  local errorcodes = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0, { namespace = namespace })) do
    table.insert(errorcodes, tostring(diagnostic.code))
  end
  return errorcodes
end

vim.api.nvim_buf_add_user_command(0, 'ShellCheckWiki', function(opts)
  vim.fn['external#browser'](
    'https://github.com/koalaman/shellcheck/wiki/SC' .. opts.args
  )
end, {
  nargs = 1,
  complete = buf_shellcheck_error_codes,
})
