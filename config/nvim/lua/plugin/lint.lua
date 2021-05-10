local lint = require("lint")
local utils = require("core.utils")

lint.linters_by_ft = {
  bash = { "shellcheck" },
  python = { "flake8", "mypy" },
}

utils.create_augroups({
  auto_linting = { "BufWritePost *.py lua require('lint').try_lint()" },
})
