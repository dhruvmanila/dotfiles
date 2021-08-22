dm.command("ShellCheckWiki", function(errorcode)
  vim.fn["external#browser"](
    "https://github.com/koalaman/shellcheck/wiki/SC" .. errorcode
  )
end, {
  buffer = true,
  nargs = 1,
})
