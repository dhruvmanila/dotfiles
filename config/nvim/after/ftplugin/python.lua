vim.cmd [[
setlocal makeprg=python3\ %
setlocal formatprg=black\ -q\ -
]]

-- To make it compatible with jupytext percent format
vim.b.slime_cell_delimiter = "# %%"

-- TODO: make it smarter about namespace using dot notation
dm.nnoremap("gk", function()
  vim.fn["external#browser"](
    ("https://docs.python.org/3.9/search.html?q=%s"):format(
      vim.fn.expand "<cword>"
    )
  )
end, {
  buffer = true,
})
