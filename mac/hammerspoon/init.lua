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
local ok, inspect = pcall(require, 'inspect')

-- Enhanced version of the builtin `print`.
--
-- The library cannot inspect a 'userdata' but hammerspoon has provided a
-- string representation for all the objects which we can get using `tostring`.
dump = function(...)
  return table.concat(
    hs.fnutils.imap({ ... }, function(value)
      if type(value) == 'table' then
        return inspect(hs.fnutils.imap(value, dump))
      elseif ok and type(value) ~= 'userdata' then
        return inspect(value)
      else
        return tostring(value)
      end
    end),
    '\n'
  )
end

-- Console style changes {{{1
hs.console.consoleFont { name = 'JetBrains Mono', size = 14.0 }
hs.console.darkMode(true)

-- Keep the color of output and window background color the same.
hs.console.outputBackgroundColor { white = 0.12 }
hs.console.windowBackgroundColor { white = 0.12 }

-- In the output area:
--
--    > command
--    result
hs.console.consoleCommandColor { white = 1 }
hs.console.consoleResultColor(hs.drawing.color.asRGB { hex = '#8ec07c' })

-- Remove the space occupying toolbar.
hs.console.toolbar(nil)

-- Keybindings {{{1

-- Toggle hammerspoon console.
hs.hotkey.bind({ 'cmd', 'ctrl', 'alt' }, 'h', function()
  hs.toggleConsole()
end)

-- macOS has provided a shortcut to minimize a window but not to unminimize them.
--
-- This only unminimizes the first window in the *current* space. Repeated
-- presses will unminimize all the remaining windows.
--
-- Also, if you have multiple windows for an application, minimize/unminimize
-- works on a specific window and not on the whole application. Use hide/unhide
-- for all windows of an application.
hs.hotkey.bind({ 'cmd', 'ctrl' }, 'm', function()
  for _, win in ipairs(hs.window.allWindows()) do
    if win:isMinimized() then
      win:unminimize()
      break
    end
  end
end)
