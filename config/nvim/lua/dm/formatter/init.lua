local api = vim.api
local lsp_util = vim.lsp.util

local format = require 'dm.formatter.format'
local register = format.register

-- c, cpp {{{1

register({ 'c', 'cpp' }, {
  cmd = 'clang-format',
  args = function(bufnr)
    return {
      '--assume-filename',
      api.nvim_buf_get_name(bufnr),
      '--style',
      'file',
    }
  end,
  enable = function(bufnr)
    return not vim.tbl_isempty(vim.fs.find({ '.clang-format' }, {
      path = api.nvim_buf_get_name(bufnr),
      upward = true,
      type = 'file',
    }))
  end,
})

-- go {{{1

register('go', {
  lsp = {
    format = true,
  },
})

-- html, javascript, json, typescript, yaml {{{1

register({
  'html',
  'javascript',
  'json',
  'typescript',
  'yaml',
}, {
  cmd = 'prettier',
  args = function(bufnr)
    return {
      '--tab-width',
      vim.lsp.util.get_effective_tabstop(bufnr),
      '--stdin-filepath',
      vim.api.nvim_buf_get_name(bufnr),
    }
  end,
})

-- }}}1
-- lua {{{1

do
  local stylua_config_path

  register('lua', {
    cmd = 'stylua',
    args = function()
      return { '--config-path', stylua_config_path, '-' }
    end,
    enable = function(bufnr)
      stylua_config_path = vim.fs.find({ 'stylua.toml', '.stylua.toml' }, {
        path = api.nvim_buf_get_name(bufnr),
        upward = true,
        type = 'file',
      })[1]
      return stylua_config_path ~= nil
    end,
  })
end

-- python {{{1

register('python', {
  {
    cmd = 'black',
    args = { '--fast', '--quiet', '--target-version', 'py310', '-' },
  },
  {
    cmd = 'isort',
    args = { '-' },
  },
})

-- rust {{{1

register('rust', {
  cmd = 'rustfmt',
})

-- sh {{{1

register('sh', {
  cmd = 'shfmt',
  args = function(bufnr)
    local indent_size = vim.bo.expandtab
        and lsp_util.get_effective_tabstop(bufnr)
      or 0
    return { '-i', indent_size, '-bn', '-ci', '-sr', '-' }
  end,
})

-- sql {{{1

register('sql', {
  cmd = 'sqlformat',
  args = { '--reindent', '--keywords', 'upper', '--wrap_after', '80', '-' },
})

-- xml {{{1

register('xml', {
  cmd = 'xmllint',
  args = { '--format', '-' },
})

return { format = format.format }
