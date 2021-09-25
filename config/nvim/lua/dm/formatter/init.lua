local api = vim.api
local lsp_util = vim.lsp.util

local register = require("dm.formatter.format").register
local root_pattern = require("lspconfig.util").root_pattern

-- Returns a function which will check whether the given path is in one of the
-- provided project names.
--
-- This will be useful when there are certain projects which aren't using any
-- formatters. I don't want to manually toggle auto-formatting.
---@return fun(path: string): boolean
local function ignore_projects(...)
  local projects = { ... }
  return function(path)
    local components = vim.split(path, "/")
    for _, component in ipairs(components) do
      if vim.tbl_contains(projects, component) then
        return true
      end
    end
    return false
  end
end

local finder = {
  stylua_config_file = root_pattern "stylua.toml",
  py_ignore_projects = ignore_projects("infogami", "openlibrary"),
}

do
  local stylua_config_dir

  register("lua", {
    cmd = "stylua",
    args = function()
      return { "--config-path", stylua_config_dir .. "/stylua.toml", "-" }
    end,
    enable = function()
      stylua_config_dir = finder.stylua_config_file(api.nvim_buf_get_name(0))
      return stylua_config_dir ~= nil
    end,
  })
end

register("python", {
  {
    cmd = "black",
    args = { "--fast", "--quiet", "-" },
    enable = function()
      return not finder.py_ignore_projects(api.nvim_buf_get_name(0))
    end,
  },
  {
    cmd = "isort",
    args = { "--profile", "black", "-" },
    enable = function()
      return not finder.py_ignore_projects(api.nvim_buf_get_name(0))
    end,
  },
})

register("sh", {
  cmd = "shfmt",
  args = function()
    local indent_size = vim.bo.expandtab
        and lsp_util.get_effective_tabstop()
      or 0
    return { "-i", indent_size, "-bn", "-ci", "-sr", "-" }
  end,
})

register("json", { use_lsp = true })

register("yaml", {
  cmd = "prettier",
  args = function()
    local tabwidth = lsp_util.get_effective_tabstop()
    return { "--parser", "yaml", "--tab-width", tabwidth }
  end,
})

register("sql", {
  cmd = "sqlformat",
  args = { "--reindent", "--keywords", "upper", "--wrap_after", "80", "-" },
})
