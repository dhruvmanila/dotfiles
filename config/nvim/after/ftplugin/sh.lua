-- Language server name for shell files.
local SERVER_NAME = 'bashls'

---@type number?
local namespace

-- Return a list of diagnostic codes of the current buffer for shellcheck.
---@return string[]
local function buf_shellcheck_error_codes()
  if namespace == nil then
    local client_id = vim.lsp.get_clients({
      bufnr = vim.api.nvim_get_current_buf(),
      name = SERVER_NAME,
    })[1].id
    namespace = vim.api.nvim_get_namespaces()[('vim.lsp.%s.%d'):format(SERVER_NAME, client_id)]
  end
  local errorcodes = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0, { namespace = namespace })) do
    -- This is to avoid duplicates.
    errorcodes[tostring(diagnostic.code)] = true
  end
  return vim.tbl_keys(errorcodes)
end

vim.api.nvim_buf_create_user_command(0, 'ShellCheckWiki', function(opts)
  vim.ui.open('https://github.com/koalaman/shellcheck/wiki/' .. opts.args)
end, {
  nargs = 1,
  complete = buf_shellcheck_error_codes,
  desc = 'Open ShellCheck wiki for the given error code',
})
