local lint = require("lint")

lint.linters_by_ft = {
  bash = { "shellcheck" },
  python = { "flake8", "mypy" },
}

dm.augroup("auto_linting", {
  {
    events = { "BufWritePost" },
    targets = { "*" },
    command = lint.try_lint,
  },
})
