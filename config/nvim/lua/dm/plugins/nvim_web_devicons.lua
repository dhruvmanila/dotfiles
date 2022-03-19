local nvim_web_devicons = require 'nvim-web-devicons'

local custom_icons = {
  TelescopePrompt = {
    icon = '',
    color = '#f38019',
    name = 'TelescopePrompt',
  },
  Dashboard = {
    icon = '',
    color = '#787878',
    name = 'Dashboard',
  },
  ['[packer]'] = {
    icon = '',
    color = '#787878',
    name = 'Packer',
  },
  lir_folder_icon = {
    icon = '',
    color = '#7ebae4',
    name = 'LirFolderNode',
  },
}

if not nvim_web_devicons.has_loaded() then
  nvim_web_devicons.setup {
    override = custom_icons,
    default = true,
  }
else
  nvim_web_devicons.set_icon(custom_icons)
end
