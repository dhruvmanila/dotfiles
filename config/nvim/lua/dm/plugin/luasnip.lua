local luasnip = require "luasnip"

luasnip.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}
