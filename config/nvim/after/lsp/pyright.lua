---@diagnostic disable: inject-field

-- Path to `mypy_primer` projects directory.
local MYPY_PRIMER_PROJECTS_DIR = '/private/tmp/mypy_primer/projects'

-- Check if the `root_dir` is in the `mypy_primer` projects directory and return the virtual
-- environment corresponding to that project if it exists.
---@param root_dir string
---@return string|nil
local function find_mypy_primer_venv(root_dir)
  if not dm.path_exists(MYPY_PRIMER_PROJECTS_DIR) then
    return
  end
  local relative_path = vim.fs.relpath(MYPY_PRIMER_PROJECTS_DIR, root_dir)
  if not relative_path then
    return
  end
  local project_name = vim.split(relative_path, '/', { plain = true })[1]
  local venv_dir = vim.fs.joinpath(MYPY_PRIMER_PROJECTS_DIR, '_' .. project_name .. '_venv')
  if not dm.path_exists(venv_dir) then
    return
  end
  return venv_dir
end

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
    local mypy_primer_venv_dir = find_mypy_primer_venv(config.root_dir)
    if mypy_primer_venv_dir then
      config.settings.python.venvPath = mypy_primer_venv_dir
      config.settings.python.pythonPath = vim.fs.joinpath(mypy_primer_venv_dir, 'bin', 'python')
      return
    end
  end,
}
