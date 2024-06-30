local has_telescope, telescope = pcall(require, 'telescope')

if not has_telescope then
  dm.log.warn '`telsecope.nvim` is unavailable, cannot register custom telescope extensions'
  return
end

return telescope.register_extension {
  exports = {
    github_stars = require 'telescope._extensions.custom.github_stars',
    installed_plugins = require 'telescope._extensions.custom.installed_plugins',
  },
}
