local g = vim.g
local icons = require "dm.icons"

g.vista_default_executive = "nvim_lsp"
g.vista_sidebar_width = 35
g.vista_sidebar_keepalt = 1

-- Update the Vista window on TextChanged and TextChangedI after a delay.
g.vista_update_on_text_changed = 1
g.vista_update_on_text_changed_delay = 1000

-- I have my own custom statusline.
g.vista_disable_statusline = 1

-- Open the symbol at cursor in a floating window after a delay.
g.vista_echo_cursor = 0
g.vista_echo_cursor_strategy = "floating_win"
g.vista_cursor_delay = 600

g.vista_executive_for = {
  markdown = "toc",
  help = "ctags",
}

g["vista#renderer#enable_icon"] = 1
g["vista#renderer#icons"] = (function()
  local items = {}
  for _, info in ipairs(icons.lsp_kind) do
    local icon, name = unpack(info)
    items[name:lower()] = icon
  end
  return items
end)()

vim.api.nvim_set_keymap(
  "n",
  "<Leader>vv",
  "<Cmd>Vista!!<CR>",
  { noremap = true }
)
