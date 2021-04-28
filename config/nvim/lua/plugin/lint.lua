local lint = require('lint')

lint.linters_by_ft = {
  bash = {'shellcheck'},
  python = {'flake8', 'mypy'},
}
