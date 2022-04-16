-- Custom telescope themes used in multiple parts of the config.
local M = {}

local themes = require 'telescope.themes'

M.dropdown_list = themes.get_dropdown {
  layout_config = {
    width = 50,
    height = 0.5,
  },
  previewer = false,
}

return M
