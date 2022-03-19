local api = vim.api
local lsp_util = vim.lsp.util

local register = require('dm.formatter.format').register
local root_pattern = require('lspconfig.util').root_pattern
local path = require('lspconfig.util').path

local finder = {
  stylua_config_file = root_pattern('.stylua.toml', 'stylua.toml'),
  clang_format_config_file = root_pattern '.clang-format',
}

-- c, cpp {{{1

register({ 'c', 'cpp' }, {
  cmd = 'clang-format',
  args = function()
    return {
      '--assume-filename',
      api.nvim_buf_get_name(0),
      '--style',
      'file',
    }
  end,
  enable = function()
    return finder.clang_format_config_file(api.nvim_buf_get_name(0)) ~= nil
  end,
})

-- go {{{1

register('go', {
  lsp = {
    format = true,
    code_actions = { 'source.organizeImports' },
  },
})

-- javascript, json, typescript {{{1

register({
  'javascript',
  'json',
  'typescript',
}, {
  lsp = {
    format = true,
  },
})

-- lua {{{1

do
  local stylua_config_dir
  local possible_filenames = {
    'stylua.toml',
    '.stylua.toml',
  }

  register('lua', {
    cmd = 'stylua',
    args = function()
      local stylua_config_path
      for _, filename in ipairs(possible_filenames) do
        stylua_config_path = stylua_config_dir .. '/' .. filename
        if path.exists(stylua_config_path) then
          break
        end
      end
      return { '--config-path', stylua_config_path, '-' }
    end,
    enable = function()
      stylua_config_dir = finder.stylua_config_file(api.nvim_buf_get_name(0))
      return stylua_config_dir ~= nil
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

-- sh {{{1

register('sh', {
  cmd = 'shfmt',
  args = function()
    local indent_size = vim.bo.expandtab and lsp_util.get_effective_tabstop()
      or 0
    return { '-i', indent_size, '-bn', '-ci', '-sr', '-' }
  end,
})

-- sql {{{1

register('sql', {
  cmd = 'sqlformat',
  args = { '--reindent', '--keywords', 'upper', '--wrap_after', '80', '-' },
})

-- yaml {{{1

register('yaml', {
  cmd = 'prettier',
  args = function()
    local tabwidth = lsp_util.get_effective_tabstop()
    return { '--parser', 'yaml', '--tab-width', tabwidth }
  end,
})
