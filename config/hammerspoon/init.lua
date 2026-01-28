---@diagnostic disable: undefined-global

-- Why do we need to always load this module?
--
--   > The command line tool will not work unless the `hs.ipc` module is loaded
--   > first, so it is recommended that you add `require("hs.ipc")` to your
--   > Hammerspoon `init.lua` file (usually located at ~/.hammerspoon/init.lua)
--   > so that it is always available when Hammerspoon is running.
--
-- See: https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/ipc/init.lua
if not hs.ipc.cliStatus() then
  hs.ipc.cliInstall()
end

-- Disable animations
hs.window.animationDuration = 0

-- `vim.inspect` for the hammerspoon console
--
-- This requires the `inspect` library to be installed via `luarocks` in the
-- global environment:
--
--     $ luarocks install inspect
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

-- Console style changes
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

-- Keybindings

-- Toggle hammerspoon console.
hs.hotkey.bind({ 'cmd', 'ctrl', 'alt' }, 'h', function()
  hs.toggleConsole()
end)

-- Automatically adjust Kitty's font size based on which display it's on.
--
-- This requires the following Kitty config:
--
-- ```
-- allow_remote_control socket-only
-- listen_on unix:/tmp/mykitty
-- ```
local kittyFontSizes = {
  builtin = 16, -- Laptop display
  external = 18, -- External monitor
}

-- Find the Kitty socket in `/tmp` directory.
--
-- This assumes that the socket is named `mykitty-<pid>`. Returns `nil` if not found.
local function findKittySocket()
  for file in hs.fs.dir '/tmp' do
    if file:match '^mykitty%-%d+$' then
      return 'unix:/tmp/' .. file
    end
  end
  return nil
end

-- Set Kitty font size via remote control.
---@param size number
local function setKittyFontSize(size)
  local socket = findKittySocket()
  if not socket then
    return
  end
  hs.task
    .new('/opt/homebrew/bin/kitty', nil, {
      '@',
      '--to',
      socket,
      'set-font-size',
      tostring(size),
    })
    :start()
end

local function adjustKittyFontForScreen(win)
  if not win then
    return
  end
  local screen = win:screen()
  if not screen then
    return
  end
  local screenName = screen:name()
  -- "Built-in" appears in the name for laptop displays
  local isBuiltin = screenName:find 'Built%-in' ~= nil
  local size = isBuiltin and kittyFontSizes.builtin or kittyFontSizes.external
  setKittyFontSize(size)
end

local kittyFilter = hs.window.filter.new 'kitty'
kittyFilter:subscribe(hs.window.filter.windowMoved, adjustKittyFontForScreen)
kittyFilter:subscribe(hs.window.filter.windowFocused, adjustKittyFontForScreen)

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
