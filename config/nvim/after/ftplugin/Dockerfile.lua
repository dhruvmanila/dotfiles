---@type number
local namespace =
  vim.api.nvim_get_namespaces()['dm__diagnostics_Dockerfile_hadolint']

-- Return a list of diagnostic codes of the current buffer for shellcheck.
---@return string[]
local function buf_hadolint_error_codes()
  local errorcodes = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0, { namespace = namespace })) do
    table.insert(errorcodes, tostring(diagnostic.code))
  end
  return errorcodes
end

vim.api.nvim_buf_create_user_command(0, 'HadolintWiki', function(opts)
  vim.fn['external#browser'](
    'https://github.com/hadolint/hadolint/wiki/' .. opts.args
  )
end, {
  nargs = 1,
  complete = buf_hadolint_error_codes,
})
