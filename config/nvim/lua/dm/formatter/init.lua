local api = vim.api
local lsp_util = vim.lsp.util

local register = require("dm.formatter.format").register
local root_pattern = require("lspconfig.util").root_pattern

local finder = {
  stylua_config_file = root_pattern "stylua.toml",
  clang_format_config_file = root_pattern ".clang-format",
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
    args = { "--fast", "--quiet", "--target-version", "py310", "-" },
  },
  {
    cmd = "isort",
    args = { "--profile", "black", "-" },
  },
})

register({ "c", "cpp" }, {
  cmd = "clang-format",
  args = function()
    return {
      "--assume-filename",
      api.nvim_buf_get_name(0),
      "--style",
      "file",
    }
  end,
  enable = function()
    return finder.clang_format_config_file(api.nvim_buf_get_name(0)) ~= nil
  end,
})

register({ "go", "json" }, { use_lsp = true })

register("sh", {
  cmd = "shfmt",
  args = function()
    local indent_size = vim.bo.expandtab and lsp_util.get_effective_tabstop()
      or 0
    return { "-i", indent_size, "-bn", "-ci", "-sr", "-" }
  end,
})

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
