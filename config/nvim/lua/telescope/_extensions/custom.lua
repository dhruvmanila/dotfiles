local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
  return
end

-- Global variable to hold the config values for all of my custom pickers.
-- This is a map from custom picker name to the config table.
---@type table<string, table>
_TelescopeCustomExtensionsConfig = _TelescopeCustomExtensionsConfig or {}

-- Requires only when the module is called.
--
-- This is specifically for the custom telescope extensions module as the given
-- extension name is prefixed with the path to the custom module.
---@see https://github.com/tjdevries/lazy.nvim
local function require_on_module_call(custom_module_name)
  return setmetatable({}, {
    __call = function(_, ...)
      return require('telescope._extensions.custom.' .. custom_module_name)(...)
    end,
  })
end

return telescope.register_extension {
  setup = function(ext_config)
    _TelescopeCustomExtensionsConfig = vim.tbl_deep_extend(
      'force',
      _TelescopeCustomExtensionsConfig,
      ext_config
    )
  end,
  exports = {
    github_stars = require_on_module_call 'github_stars',
    icons = require_on_module_call 'icons',
    installed_plugins = require_on_module_call 'installed_plugins',
    lir_cd = require_on_module_call 'lir_cd',
    sessions = require_on_module_call 'sessions',
    websearch = require_on_module_call 'websearch',
  },
}
