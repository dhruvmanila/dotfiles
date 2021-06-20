require "dm.globals.utils"

-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals/init.lua
---@generic T
---@param v T
---@return T
P = function(v)
  print(vim.inspect(v))
  return v
end

-- Clear the 'require' cache for the module name.
---@param name string
RELOAD = function(name)
  package.loaded[name] = nil
end

-- Reload and require the givem module name.
---@param name string
---@return any
R = function(name)
  RELOAD(name)
  return require(name)
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

do
  local output = "[timer]%s: %fms"
  local hrtime = vim.loop.hrtime
  local start = nil

  -- Simple interface for timing code chunks.
  _G.timer = {
    start = function()
      start = hrtime()
    end,
    stop = function(info)
      print(output:format(info and " " .. info or "", (hrtime() - start) / 1e6))
      start = nil
    end,
  }
end
