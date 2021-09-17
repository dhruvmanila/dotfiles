local opt_local = vim.opt_local

opt_local.makeprg = "$SHELL %"

-- Return a list of diagnostic codes of the current buffer for shellcheck.
---@return string[]
function _G.buf_shellcheck_error_codes()
  local errorcodes = {}
  for _, diagnostic in ipairs(vim.lsp.diagnostic.get()) do
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
