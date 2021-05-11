local icons = require("core.icons").icons
local kind_icons = require("core.icons").lsp_kind
local lspstatus = require("lsp-status")

local plugins = {}

lspstatus.config({
  -- The sumneko lua server sends valueRange (which is not specified in the
  -- protocol) to give the range for a function's start and end.
  select_symbol = function(cursor_pos, symbol)
    if symbol.valueRange then
      local value_range = {
        ["start"] = {
          character = 0,
          line = vim.fn.byte2line(symbol.valueRange[1]),
        },
        ["end"] = {
          character = 0,
          line = vim.fn.byte2line(symbol.valueRange[2]),
        },
      }
      return require("lsp-status.util").in_range(cursor_pos, value_range)
    end
  end,
  kind_labels = (function()
    local items = {}
    for _, info in ipairs(kind_icons) do
      local icon, name = unpack(info)
      items[name] = icon
    end
    return items
  end)(),
  indicator_errors = icons.error,
  indicator_warnings = icons.warning,
  indicator_info = icons.info,
  indicator_hint = icons.hint,
})
-- Register the progress handler with Neovim's LSP client.
lspstatus.register_progress()

-- Include all the plugins `on_attach` calls in this function which should be
-- called in the main `on_attach` function in `lsp/init.lua`
function plugins.on_attach(client)
  lspstatus.on_attach(client)
end

return plugins
