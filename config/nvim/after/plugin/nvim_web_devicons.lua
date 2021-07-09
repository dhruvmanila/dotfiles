require("nvim-web-devicons").setup {
  -- your personnal icons can go here (to override)
  -- DevIcon will be appended to `name`
  override = {
    ["TelescopePrompt"] = {
      icon = "",
      color = "#f38019",
      name = "TelescopePrompt",
    },
    ["Dashboard"] = {
      icon = "",
      color = "#787878",
      name = "Dashboard",
    },
  },
  -- globally enable default icons (default to false)
  -- will get overriden by `get_icons` option
  default = true,
}
