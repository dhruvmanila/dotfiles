require("core.globals.utils")

-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals/init.lua
P = function(v)
  print(vim.inspect(v))
  return v
end

if pcall(require, "plenary") then
  RELOAD = require("plenary.reload").reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

-- Dump the contents of the given arguments.
---@vararg any
function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(table.concat(objects, "\n"))
end

-- Determine whether the given plugin is currently loaded or not.
---@param plugin_name string
---@return boolean
function _G.plugin_loaded(plugin_name)
  local plugins = _G.packer_plugins or {}
  return plugins[plugin_name] and plugins[plugin_name].loaded
end
