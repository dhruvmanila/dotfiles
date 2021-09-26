---@type number
local namespace = vim.api.nvim_get_namespaces()["dm__diagnostics_sh_shellcheck"]

-- Return a list of diagnostic codes of the current buffer for shellcheck.
---@return string[]
function _G.buf_shellcheck_error_codes()
  local errorcodes = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0, { namespace = namespace })) do
    table.insert(errorcodes, tostring(diagnostic.code))
  end
  return errorcodes
end

dm.command("ShellCheckWiki", function(errorcode)
  vim.fn["external#browser"](
    "https://github.com/koalaman/shellcheck/wiki/SC" .. errorcode
  )
end, {
  buffer = true,
  nargs = 1,
  complete = "customlist,v:lua.buf_shellcheck_error_codes",
})
