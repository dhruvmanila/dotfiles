---@diagnostic disable: undefined-global
-- Why do we need to always load this module? {{{
--
--   > The command line tool will not work unless the `hs.ipc` module is loaded
--   > first, so it is recommended that you add `require("hs.ipc")` to your
--   > Hammerspoon `init.lua` file (usually located at ~/.hammerspoon/init.lua)
--   > so that it is always available when Hammerspoon is running.
--
-- See: https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/ipc/init.lua
-- }}}
if not hs.ipc.cliStatus() then
  hs.ipc.cliInstall()
end
