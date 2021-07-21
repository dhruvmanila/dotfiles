local opt_local = vim.opt_local

-- Run with :make
opt_local.makeprg = "python3 %"

-- Format with 'gq'
opt_local.formatprg = "black -q -"

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
