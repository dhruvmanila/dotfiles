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
  vim.lsp.enable { 'pyrefly', 'pyright', 'ty' }
  vim.lsp.enable('ruff', false)
end

-- Setup for the any of the projects configured for mypy_primer.
local function setup_mypy_primer()
  require('dm.linter').enabled_linters_by_filetype.python = { 'mypy' }
  -- These are the release binaries built when running `mypy_primer` that should exists when I'm
  -- trying to analyze the output.
  vim.lsp.enable { 'ty_mypy_primer_new', 'ty_mypy_primer_old', 'pyright', 'pyrefly' }
  vim.lsp.enable('ruff', false)
  vim.lsp.enable('ty', false)

  -- Override the `on_diagnostic` handler to update the diagnostic source to use the language server
  -- name instead of "ty".
  local original_on_diagnostic = vim.lsp.diagnostic.on_diagnostic

  ---@param error lsp.ResponseError?
  ---@param result lsp.DocumentDiagnosticReport
  ---@param ctx lsp.HandlerContext
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.diagnostic.on_diagnostic = function(error, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if
      result.items ~= nil
      and client ~= nil
      and (client.name == 'ty_mypy_primer_new' or client.name == 'ty_mypy_primer_old')
    then
      local source
      if client.name == 'ty_mypy_primer_new' then
        source = 'ty (new)'
      else
        source = 'ty (old)'
      end
      for _, item in ipairs(result.items) do
        item.source = source
      end
    end
    original_on_diagnostic(error, result, ctx)
  end
end

-- Setup for the ty server playground.
local function setup_ty_server_playground()
  setup_playground_diagnostic()
  vim.lsp.enable({ 'pyrefly', 'pyright', 'ruff' }, false)
  vim.lsp.enable 'ty'
end

-- Setup for the Pyright server playground.
local function setup_pyright_server_playground()
  vim.lsp.enable({ 'pyrefly', 'ruff', 'ty' }, false)
  vim.lsp.config('pyright', {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = 'strict',
        },
      },
    },
  })
  vim.lsp.enable 'pyright'
end

-- Setup for the Pyrefly server playground.
local function setup_pyrefly_server_playground()
  vim.lsp.enable({ 'ruff', 'ty', 'pyright' }, false)
  vim.lsp.enable 'pyrefly'
end

local function setup_finlab()
  vim.lsp.enable 'pyright'
  vim.lsp.enable('ty', false)
end

---@type table<string, function>
local DIRECTORIES = {
  [dm.OS_HOMEDIR .. '/work/astral/ruff/'] = setup_ruff,
  [dm.OS_HOMEDIR .. '/work/astral/ruff-test/'] = setup_ruff,
  [dm.OS_HOMEDIR .. '/playground/ruff/'] = setup_ruff_playground,
  [dm.OS_HOMEDIR .. '/playground/ty/'] = setup_ty_playground,
  [dm.OS_HOMEDIR .. '/playground/ty-server/'] = setup_ty_server_playground,
  [dm.OS_HOMEDIR .. '/playground/pyright-server/'] = setup_pyright_server_playground,
  [dm.OS_HOMEDIR .. '/playground/pyrefly-server/'] = setup_pyrefly_server_playground,
  [dm.OS_HOMEDIR .. '/work/astral/mypy_primer_diffs/'] = setup_mypy_primer,
  [dm.OS_HOMEDIR .. '/projects/finlab'] = setup_finlab,
}

-- Perform project specific setup.
function M.setup()
  for directory, setup_fn in pairs(DIRECTORIES) do
    if vim.startswith(dm.CWD .. '/', directory) then
      dm.log.info('Setting up project specific configuration under %s', directory)
      setup_fn()
    end
  end
end

return M
