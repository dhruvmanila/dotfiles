local lsp_util = vim.lsp.util
local register = require("dm.formatter.format").register
local root_pattern = require("lspconfig.util").root_pattern

local finder = {
  stylua_config_file = root_pattern "stylua.toml",
  ignore_projects = root_pattern("openlibrary", "infogami"),
}

do
  local stylua_config_dir

  register("lua", {
    cmd = "stylua",
    args = function()
      return { "--config-path", stylua_config_dir .. "/stylua.toml", "-" }
    end,
    enable = function(_, path)
      stylua_config_dir = finder.stylua_config_file(path)
      if not stylua_config_dir then
        return false
      end
    end,
    stdin = true,
  })
end

register("python", {
  {
    cmd = "black",
    args = { "--fast", "--quiet", "-" },
    enable = function(_, path)
      if finder.ignore_projects(path) then
        return false
      end
    end,
    stdin = true,
  },
  {
    cmd = "isort",
    args = { "--profile", "black", "-" },
    enable = function(_, path)
      if finder.ignore_projects(path) then
        return false
      end
    end,
    stdin = true,
  },
})

register("sh", {
  cmd = "shfmt",
  args = function(bufnr)
    local indent_size = vim.bo[bufnr].expandtab
        and lsp_util.get_effective_tabstop(bufnr)
      or 0
    return { "-i", indent_size, "-bn", "-ci", "-sr", "-kp", "-" }
  end,
  stdin = true,
})

register("json", { use_lsp = true })

register("yaml", {
  cmd = "prettier",
  args = function(bufnr)
    local tabwidth = lsp_util.get_effective_tabstop(bufnr)
    return { "--parser", "yaml", "--tab-width", tabwidth }
  end,
  stdin = true,
})
