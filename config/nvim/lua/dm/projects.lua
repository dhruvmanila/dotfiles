local M = {}

-- Setup for the ruff project.
local function setup_ruff()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('dm__lsp_attach_ruff', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client == nil then
        return
      end
      if client.name == 'rust_analyzer' then
        -- Override the existing key binding to only include diagnostics from rust-analyzer.
        vim.keymap.set('n', '<leader>fd', function()
          require('telescope.builtin').diagnostics {
            prompt_title = 'Workspace Diagnostics (rust-analyzer)',
            namespace = vim.lsp.diagnostic.get_namespace(client.id),
          }
        end, {
          buffer = args.data.buffer,
          desc = 'telescope: rust-analyzer diagnostics',
        })
      end
    end,
  })
end

-- Setup the diagnostic configuration for the playground projects.
--
-- The configuration includes:
-- - Underline the diagnostic ranges
local function setup_playground_diagnostic()
  vim.diagnostic.config {
    underline = true,
  }
end

-- Setup for the ruff playground.
local function setup_ruff_playground()
  require('dm.linter').enabled_linters_by_filetype.python = { 'flake8', 'pylint', 'mypy' }
  setup_playground_diagnostic()
end

-- Setup for the ty playground.
local function setup_ty_playground()
  require('dm.linter').enabled_linters_by_filetype.python = { 'mypy' }
  setup_playground_diagnostic()
  vim.lsp.enable { 'ty', 'pyrefly' }
  vim.lsp.enable('ruff', false)
end

-- Setup for the any of the projects configured for mypy_primer.
local function setup_mypy_primer()
  vim.lsp.enable 'ty_main'
end

---@type table<string, function>
local DIRECTORIES = {
  [dm.OS_HOMEDIR .. '/work/astral/ruff'] = setup_ruff,
  [dm.OS_HOMEDIR .. '/work/astral/ruff-test'] = setup_ruff,
  [dm.OS_HOMEDIR .. '/playground/ruff'] = setup_ruff_playground,
  [dm.OS_HOMEDIR .. '/playground/ty'] = setup_ty_playground,
  ['/tmp/mypy_primer/projects'] = setup_mypy_primer,
}

-- Perform project specific setup.
function M.setup()
  for directory, setup_fn in pairs(DIRECTORIES) do
    if vim.startswith(dm.CWD, directory) then
      dm.log.info('Setting up project specific configuration under %s', directory)
      setup_fn()
    end
  end
end

return M
