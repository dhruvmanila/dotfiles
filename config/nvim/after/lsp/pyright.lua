-- https://github.com/microsoft/pyright
-- Install: `npm install --global pyright`
-- Settings: https://github.com/microsoft/pyright/blob/master/docs/settings.md
---@type vim.lsp.Config
return {
  settings = {
    pyright = {
      disableOrganizeImports = true, -- Using Ruff's import organizer
    },
    python = {
      analysis = {
        stubPath = dm.OS_HOMEDIR .. '/work/astral/ruff/crates/red_knot_vendored/knot_extensions',
      },
    },
  },
  before_init = function(_, config)
    -- We could use `vim.fs.find` if the need arises.
    local venv_dir = vim.fs.joinpath(config.root_dir, '.venv')
    if dm.path_exists(venv_dir) then
      config.settings.python.venvPath = venv_dir
      config.settings.python.pythonPath = vim.fs.joinpath(venv_dir, 'bin', 'python')
    end
  end,
}
