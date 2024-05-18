---@enum Scope
local Scope = {
  GLOBAL = 1,
  BUFFER = 2,
}

-- Notifies the user when auto-formatting is turned on or off globally or for
-- the current buffer.
---@param scope Scope
local function format_toggle_notify(scope)
  local msg = 'Autoformatting turned '
  if scope == Scope.BUFFER then
    if vim.b.disable_autoformat then
      msg = msg .. 'OFF for this buffer'
    else
      msg = msg .. 'ON for this buffer'
    end
  elseif scope == Scope.GLOBAL then
    if vim.g.disable_autoformat then
      msg = msg .. 'OFF'
    else
      msg = msg .. 'ON'
    end
  end
  dm.notify('FormatToggle', msg)
end

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo', 'FormatToggle' },
  keys = {
    {
      ';f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = { 'n', 'x' },
      desc = 'Format buffer',
    },
  },
  config = function()
    require('conform').setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format', 'ruff_organize_imports' },
        yaml = { 'prettier' },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
      formatters = {
        ruff_organize_imports = {
          command = 'ruff',
          args = {
            'check',
            '--force-exclude',
            '--select=I001',
            '--fix',
            '--exit-zero',
            '--stdin-filename',
            '$FILENAME',
            '-',
          },
          stdin = true,
          cwd = require('conform.util').root_file {
            'pyproject.toml',
            'ruff.toml',
            '.ruff.toml',
          },
        },
      },
    }

    vim.api.nvim_create_user_command('FormatToggle', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        format_toggle_notify(Scope.BUFFER)
      else
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        format_toggle_notify(Scope.GLOBAL)
      end
    end, {
      desc = 'Toggle auto-formatting',
      bang = true,
    })
  end,
}
