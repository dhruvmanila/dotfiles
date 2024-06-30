local M = {}

local function setup_ruff()
  local builtin = require 'telescope.builtin'

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

-- Perform project specific setup.
function M.setup()
  local cwd = assert(vim.uv.cwd())
  local project = {
    path = cwd,
    name = vim.fs.basename(cwd),
  }

  if vim.tbl_contains({ 'ruff', 'ruff-test' }, project.name) then
    setup_ruff()
  end
end

return M
