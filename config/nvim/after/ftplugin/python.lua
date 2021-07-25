vim.cmd [[
setlocal makeprg=python3\ %
setlocal formatprg=black\ -q\ -
]]

-- TODO: do I really need this? If so then make it smarter about namespace using
-- dot notation.
dm.nnoremap("gk", function()
  vim.fn["external#browser"](
    string.format(
      "https://docs.python.org/3.9/search.html?q=%s",
      vim.fn.expand "<cWORD>"
    )
  )
end, {
  buffer = true,
})
