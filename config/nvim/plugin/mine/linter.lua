local lint = require("dm.linter").lint

dm.augroup("dm__auto_linting", {
  {
    events = { "BufEnter", "BufWritePost" },
    targets = "*",
    command = lint,
  },
})
