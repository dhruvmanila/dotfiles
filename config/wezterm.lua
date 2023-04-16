--[[
TODO:

- Update the colors to match kitty
- Understand keybindings to switch between windows and tabs
- How does the multiplexer work?
- Is there a SUPER key? Should that be same as that of kitty?
- Configure in a way to make it work on Windows machine at work
--]]

local wezterm = require 'wezterm'

local config = {}

if string.find(wezterm.target_triple, 'windows') then
  -- Windows specific settings
end

if string.find(wezterm.target_triple, 'darwin') then
  -- MacOS specific settings
end

-- In newer versions of wezterm, use the config_builder which will help
-- provide clearer error messages.
-- https://wezfurlong.org/wezterm/config/files.html#quick-start
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'GruvboxDark'

config.font = wezterm.font 'JetBrains Mono'
config.font_size = 16

config.tab_bar_at_bottom = true

-- Disable the title bar but enable the resizable border
-- Watchout for https://github.com/wez/wezterm/issues/2182 for square corners.
config.window_decorations = 'RESIZE'

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

return config
