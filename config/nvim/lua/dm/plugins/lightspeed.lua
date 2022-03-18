-- For now, I am using this plugin only as a replacement for `clever-f`. Maybe
-- in the future, if I like the `s`/`S` behavior, I might enable it, but most
-- likely remap it to a different key like `<leader>j`/`<leader>k`.

-- Do NOT set any mappings by default.
vim.g.lightspeed_no_default_keymaps = true

-- Setting lightspeed options via the `opts` table directly
local opts = require("lightspeed").opts

-- For 1-character search, only the next 'n' matches will be highlighted.
opts.limit_ft_matches = 10

-- Timeout value (ms) after which the plugin should exit f/t-mode.
opts.exit_after_idle_msecs.unlabeled = 2000

vim.keymap.set({ "n", "x", "o" }, "f", "<Plug>Lightspeed_f")
vim.keymap.set({ "n", "x", "o" }, "F", "<Plug>Lightspeed_F")
vim.keymap.set({ "n", "x", "o" }, "t", "<Plug>Lightspeed_t")
vim.keymap.set({ "n", "x", "o" }, "T", "<Plug>Lightspeed_T")
