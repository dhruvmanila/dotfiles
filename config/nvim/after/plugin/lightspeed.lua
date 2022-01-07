-- For now, I am using this plugin only as a replacement for `clever-f`. Maybe
-- in the future, if I like the `s`/`S` behavior, I might enable it, but most
-- likely remap it to a different key like `<leader>j`/`<leader>k`.

-- Why not `dm.xunmap "S"`? {{{
--
-- Short answer: `vim-surround` defines the 'S' map in visual mode.
--
-- Long answer: Alphabatically, `lightspeed` comes first and so it defines the
-- 'S' map and then `vim-surround` overrides with its own 'S' map. So, we don't
-- need to unmap it.
-- }}}

vim.keymap.del("n", "s")
vim.keymap.del("n", "S")
vim.keymap.del("x", "s")
vim.keymap.del("o", "z")

-- Setting lightspeed options via the `opts` table directly
local opts = require("lightspeed").opts

-- For 1-character search, only the next 'n' matches will be highlighted.
opts.limit_ft_matches = 10

-- Timeout value (ms) after which the plugin should exit f/t-mode.
opts.exit_after_idle_msecs.unlabeled = 2000
