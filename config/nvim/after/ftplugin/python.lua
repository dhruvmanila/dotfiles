local opt_local = vim.opt_local

-- To make it compatible with jupytext percent format
vim.b.slime_cell_delimiter = "# %%"

-- Quickly run the current file
opt_local.makeprg = "python3 %"

-- Format the files with `black` and `isort`
opt_local.formatprg = "black --quiet - | isort --quiet --profile=black -"

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
