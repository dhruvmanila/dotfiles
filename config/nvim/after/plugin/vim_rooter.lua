-- Use `:RooterToggle` to toggle between automatic and manual behaviour.
-- Use `:Rooter` to invoke Rooter manually.

local g = vim.g

-- Prefer using manual mode.
g.rooter_manual_only = 1

-- Only set the current directory for the current window.
g.rooter_cd_cmd = 'lcd'

-- These are checked breadth-first as Rooter walks up the directory tree and the
-- first match is used.
g.rooter_patterns = { '.git', 'requirements.txt' }

g.rooter_silent_chdir = 1
g.rooter_resolve_links = 1
