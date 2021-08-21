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

-- Disable animations
hs.window.animationDuration = 0

-- `vim.inspect` for the hammerspoon console {{{
--
-- This requires the `inspect` library to be installed via `luarocks` in the
-- global environment:
--
--     $ luarocks install inspect
-- }}}
local ok, inspect = pcall(require, "inspect")

-- Enhanced version of the builtin `print`.
--
-- The library cannot inspect a 'userdata' but hammerspoon has provided a
-- string representation for all the objects which we can get using `tostring`.
print = function(...)
  local output = {}
  for _, value in ipairs { ... } do
    if ok and type(value) ~= "userdata" then
      table.insert(output, inspect(value))
    else
      table.insert(output, tostring(value))
    end
  end
  return table.concat(output, "\n")
end

-- Console style changes {{{
hs.console.consoleFont { name = "JetBrains Mono", size = 14.0 }
hs.console.darkMode(true)

-- Keep the color of output and window background color the same.
hs.console.outputBackgroundColor { white = 0.12 }
hs.console.windowBackgroundColor { white = 0.12 }

-- In the output area:
--
--    > command
--    result
hs.console.consoleCommandColor { white = 1 }
hs.console.consoleResultColor(hs.drawing.color.asRGB { hex = "#8ec07c" })

-- Remove the space occupying toolbar.
hs.console.toolbar(nil)

-- }}}
