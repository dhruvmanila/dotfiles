local format = require("core.format.format")
local root_pattern = require("lspconfig.util").root_pattern

local finder = {
  stylua_config_file = root_pattern("stylua.toml"),
  ignore_projects = root_pattern("openlibrary", "infogami"),
}

local cache = {}

format.formatter("lua", {
  cmd = "stylua",
  args = function(path)
    local config_dir = cache.stylua_config_dir
      or finder.stylua_config_file(path)
    return { "--config-path", config_dir .. "/stylua.toml", "-" }
  end,
  enable = function(path)
    cache.stylua_config_dir = finder.stylua_config_file(path)
    if not cache.stylua_config_dir then
      return false
    end
  end,
  stdin = true,
})

format.formatter("python", {
  cmd = "black",
  args = { "--fast", "--quiet", "-" },
  enable = function(path)
    if finder.ignore_projects(path) then
      return false
    end
  end,
  stdin = true,
})

format.formatter("python", {
  cmd = "isort",
  args = { "--profile", "black", "-" },
  enable = function(path)
    if finder.ignore_projects(path) then
      return false
    end
  end,
  stdin = true,
})

-- Auto formatting setup
dm.augroup("auto_formatting", {
  {
    events = { "BufWritePost" },
    targets = { "*" },
    command = format.format,
  },
})
