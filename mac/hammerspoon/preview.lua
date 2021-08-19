---@diagnostic disable: undefined-global
-- NOTE: {{{
--
-- This file should *NOT* be loaded with your `init.lua`. It is only meant to be
-- used as a script to be executed at an appropriate time using the `hs` CLI tool.
--
-- The CLI tool can be installed with `hs.ipc.cliInstall()`
--
-- See: `~/.config/nvim/lua/dm/markdown.lua`
-- }}}

-- FIXME: This does not work when: {{{
--
--   1. Brave browser is closed.
--
-- For (1), Brave will reopen the tabs which were already opened when I closed
-- it. Maybe there is some check regarding that or maybe wait a bit more? Also,
-- this will open brave in the current space.
-- }}}

local kitty = hs.window.focusedWindow()

if kitty:application():name() ~= "kitty" then
  return
end

-- This is only for the non-traditional fullscreen mode {{{
--
-- If you set the `macos_traditional_fullscreen` option to `yes` in `kitty.conf`,
-- this will not work as that is not considered as fullscreen.
--
-- You can check if we are in a traditional fullscreen mode by:
--
--     hs.screen.mainScreen():fullFrame() == kitty:frame()
-- }}}
if kitty:isFullScreen() then
  kitty:setFullScreen(false)
  -- A sleep is required to let the window manager register the new state,
  -- otherwise the follow-up call to create a new brave window doesn't work.
  --
  -- The unit for the argument is `microseconds`.
  hs.timer.usleep(1 * 1e6)
end

kitty:move(hs.layout.left50)

local brave = hs.application.get "Brave Browser"
if brave then
  -- If the application is already opened, then we will create a new window. {{{
  --
  -- This window is opened in the *current* space. If it was not, we would
  -- have to move the new window to the current space.
  --
  --     win = brave:getWindow "New Tab - Brave"
  --     spaces.moveWindowToSpace(win:id(), spaces.activeSpace())
  --
  -- `spaces` is a third party library and remains undocumented for now.
  -- Source: https://github.com/asmagill/hs._asm.undocumented.spaces
  -- }}}
  brave:selectMenuItem { "File", "New Window" }
else
  --     maximum number of seconds to wait
  --     for the application to be launched ───┐
  --                                           │
  --                                           │
  brave = hs.application.open("Brave Browser", 1, true)
  --                                              │
  --                                              │
  --    additionally wait until the app has       │
  --    spawned its first window (which usually ──┘
  --    takes a bit longer)
end

-- Is there any other way to get the window object? {{{
--
--   hs.window.find(hint)
-- }}}
brave:getWindow("New Tab - Brave"):move(hs.layout.right50)

-- This will open the web address in the currently focused window.
hs.osascript.applescript [[
tell application "Brave Browser"
  open location "http://localhost:8090"
end tell
]]

-- Set the focus back to kitty
kitty:focus()
