-- Ref: https://github.com/akinsho/nvim-bufferline.lua

require('bufferline').setup {
  options = {
    numbers = 'ordinal',
    number_style = '',
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = {'', ''},
    modified_icon = require('core.icons').icons.pencil,
    tab_size = 0,
    enforce_regular_tabs = false,
  }
}
