local M = {}

local function setup_ruff()
  local action_state = require 'telescope.actions.state'
  local actions = require 'telescope.actions'
  local builtin = require 'telescope.builtin'
  local finders = require 'telescope.finders'
  local pickers = require 'telescope.pickers'
  local telescope_config = require('telescope.config').values

  vim.keymap.set('n', '<leader>fc', function()
    local crate = vim.fs.root(0, 'Cargo.toml')
    if crate == nil then
      return
    end
    builtin.find_files {
      prompt_title = ('Find Files (%s)'):format(vim.fs.basename(crate)),
      cwd = crate,
    }
  end, { desc = 'telescope: find files in the current crate' })

  vim.keymap.set('n', '<leader>fC', function()
    local crates_dir = vim.fs.joinpath(dm.CWD, 'crates')

    ---@type { path: string, name: string }[]
    local crates = {}
    for name, type in vim.fs.dir(crates_dir) do
      if type == 'directory' then
        table.insert(crates, { path = vim.fs.joinpath(crates_dir, name), name = name })
      end
    end

    pickers
      .new({}, {
        prompt_title = 'Find in crates',
        finder = finders.new_table {
          results = crates,
          entry_maker = function(entry)
            return { display = entry.name, value = entry, ordinal = entry.name }
          end,
        },
        previewer = false,
        sorter = telescope_config.generic_sorter(),
        attach_mappings = function()
          actions.select_default:replace(function(prompt_bufnr)
            local selection = action_state.get_selected_entry().value
            actions.close(prompt_bufnr)
            vim.schedule(function()
              builtin.find_files {
                prompt_title = ('Find in crate (%s)'):format(selection.name),
                cwd = selection.path,
              }
            end)
          end)
          return true
        end,
      })
      :find()
  end, { desc = 'telescope: find files in the specific crate' })

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
          builtin.diagnostics {
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

local function setup_ruff_playground()
  require('dm.linter').enabled_linters_by_filetype.python = {
    'flake8',
    'pylint',
    'mypy',
  }

  vim.diagnostic.config {
    underline = true,
    severity_sort = true,
    virtual_text = {
      source = true,
      spacing = 1,
    },
  }

  local ok, lspconfig = pcall(require, 'lspconfig')
  if ok then
    lspconfig['red_knot'].setup {
      cmd = {
        dm.OS_HOMEDIR .. '/work/astral/ruff-test/target/debug/red_knot',
        'server',
      },
      trace = 'messages',
      init_options = {
        settings = {
          logLevel = 'debug',
          logFile = vim.fn.stdpath 'log' .. '/lsp.red_knot.log',
        },
      },
    }
  end
end

-- Perform project specific setup.
function M.setup()
  local project = {
    path = dm.CWD,
    name = vim.fs.basename(dm.CWD),
  }

  if
    vim.endswith(project.path, 'astral/ruff') or vim.endswith(project.path, 'astral/ruff-test')
  then
    setup_ruff()
  elseif vim.endswith(project.path, 'playground/ruff') then
    setup_ruff_playground()
  end
end

return M
