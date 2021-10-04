---@type number
local namespace =
  vim.api.nvim_get_namespaces()["dm__diagnostics_Dockerfile_hadolint"]

-- Return a list of diagnostic codes of the current buffer for shellcheck.
---@return string[]
function _G.buf_hadolint_error_codes()
  local errorcodes = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0, { namespace = namespace })) do
    table.insert(errorcodes, tostring(diagnostic.code))
  end
  return errorcodes
end

dm.command("HadolintWiki", function(errorcode)
  vim.fn["external#browser"](
    "https://github.com/hadolint/hadolint/wiki/" .. errorcode
  )
end, {
  buffer = true,
  nargs = 1,
  complete = "customlist,v:lua.buf_hadolint_error_codes",
})
