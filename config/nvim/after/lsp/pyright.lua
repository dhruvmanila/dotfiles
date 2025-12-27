---@diagnostic disable: inject-field

local utils = require 'dm.utils'

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
        stubPath = dm.OS_HOMEDIR .. '/work/astral/ruff/crates/ty_vendored/ty_extensions',
      },
    },
  },
  before_init = function(_, config)
    if config.root_dir == nil then
      return
    end

    -- Check if there's any virtual environment in the root directory itself.
    -- We could use `vim.fs.find` if the need arises.
    local venv_dir = vim.fs.joinpath(config.root_dir, '.venv')
    if dm.path_exists(venv_dir) then
      config.settings.python.venvPath = venv_dir
      config.settings.python.pythonPath = vim.fs.joinpath(venv_dir, 'bin', 'python')
      return
    end

    -- Check if this is a `mypy_primer` project
    local mypy_primer_venv_dir = utils.find_mypy_primer_venv(config.root_dir)
    if mypy_primer_venv_dir then
      config.settings.python.venvPath = mypy_primer_venv_dir
      config.settings.python.pythonPath = vim.fs.joinpath(mypy_primer_venv_dir, 'bin', 'python')
      return
    end
  end,
}
