local lint = require "lint"

lint.linters.flake8.ignore_exitcode = true
lint.linters.mypy.ignore_exitcode = true

lint.linters_by_ft = {
  sh = { "shellcheck" },
  python = { "flake8", "mypy" },
}

dm.augroup("dm__auto_linting", {
  {
    events = "BufWritePost",
    targets = "*",
    command = lint.try_lint,
  },
})
