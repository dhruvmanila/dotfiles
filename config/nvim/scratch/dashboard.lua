-- https://github.com/glepnir/dashboard-nvim
local g = vim.g

g.dashboard_custom_header = {
  '███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
  '████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
  '██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
  '██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
  '██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
  '╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
}

g.dashboard_default_executive = 'telescope'

g.dashboard_enable_session = 1
g.dashboard_session_directory = vim.loop.os_homedir() .. '/.local/share/nvim/session'

g.dashboard_disable_statusline = 1

g.dashboard_custom_section = {
  last_session = {
    description = {"Open last session                         l"},
    command = "",
  },
  sessions = {
    description = {"Find sessions                             s"},
    command = "lua require('plugin.telescope').startify_sessions()",
  },
  files = {
    description = {"Find files                                f"},
    command = "lua require('plugin.telescope').find_files()",
  },
  new_file = {
    description = {"New file                                  e"},
    command = "DashboardNewFile",
  },
  history = {
    description = {"Find history                              h"},
    command = "Telescope oldfiles",
  },
}
