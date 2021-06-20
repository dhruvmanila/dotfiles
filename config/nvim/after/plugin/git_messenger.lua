local g = vim.g
local border = require("dm.icons").border

g.git_messenger_always_into_popup = true
g.git_messenger_floating_win_opts = { border = border[g.border_style] }
