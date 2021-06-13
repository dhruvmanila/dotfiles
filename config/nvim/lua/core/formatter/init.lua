local lsp_util = vim.lsp.util
local format = require("core.formatter.format")
local root_pattern = require("lspconfig.util").root_pattern

local finder = {
  stylua_config_file = root_pattern("stylua.toml"),
  ignore_projects = root_pattern("openlibrary", "infogami"),
}

do
  local stylua_config_dir

  format.formatter("lua", {
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

format.formatter("python", {
  cmd = "black",
  args = { "--fast", "--quiet", "-" },
  enable = function(_, path)
    if finder.ignore_projects(path) then
      return false
    end
  end,
  stdin = true,
})

format.formatter("python", {
  cmd = "isort",
  args = { "--profile", "black", "-" },
  enable = function(_, path)
    if finder.ignore_projects(path) then
      return false
    end
  end,
  stdin = true,
})

format.formatter("sh", {
  cmd = "shfmt",
  -- -i uint   indent: 0 for tabs (default), >0 for number of spaces
  -- -bn       binary ops like && and | may start a line
  -- -ci       switch cases will be indented
  -- -sr       redirect operators will be followed by a space
  -- -kp       keep column alignment paddings
  args = function(bufnr)
    local indent_size = vim.bo[bufnr].expandtab
        and lsp_util.get_effective_tabstop(bufnr)
      or 0
    return { "-i", indent_size, "-bn", "-ci", "-sr", "-kp", "-" }
  end,
  stdin = true,
})

format.formatter("json", { use_lsp = true })