-- To install the web server: {{{
--
--     $ brew install nodejs npm
--     $ git clone https://github.com/dhruvmanila/instant-markdown-d
--     $ npm -g install
-- }}}

local curl = require "plenary.curl"

-- Variables {{{1

local DEBUG = false

-- Path to the executable
local SERVER_EXEC = "instant-markdown-d"

-- The server can be configured via several environment variables.
-- Source: https://github.com/suan/instant-markdown-d#environment-variables
local SERVER_ENV = "INSTANT_MARKDOWN_ALLOW_UNSAFE_CONTENT=1"

-- `stdout` and `stderr` of the server will be redirected to this file.
local SERVER_LOG_FILE = DEBUG and "/tmp/instant_markdown_d.log" or "/dev/null"

-- Command to start the server.
local START_SERVER_CMD = string.format(
  --       ┌─ do not open the browser window by default
  --       │            ┌─ redirect stdout and stderr to `SERVER_LOG_FILE`
  --       │            │ ┌─ start the process in the background
  --       │     ┌──────┤ │
  "%s %s --debug >%s 2>&1 &",
  SERVER_ENV,
  SERVER_EXEC,
  SERVER_LOG_FILE
)

-- This script creates a split like view of the _screen_ where the left half
-- is the terminal and right half is the browser window where the file will be
-- previewed. Look at the mentioned file for more info.
--
--                                   ┌─ enable print mirroring from this instance
--                                   │  to the hammerspoon console
--                                   │
local HS_ACTIVATE_BROWSER_CMD = "hs -P ~/.hammerspoon/preview.lua"

-- The browser will be automatically closed by the server so the only task
-- remaining is to resize the terminal window.
--
-- This requires the `allow_remote_control` and `listen_on` option to be set
-- in your kitty config.
local RESIZE_KITTY_WINDOW_CMD =
  "kitty @ --to=$KITTY_LISTEN_ON resize-os-window --action=toggle-maximized"

-- State of the previewer.
local state = { active = false }

-- Functions {{{1

-- Perform the necessary tasks to restore the state.
local function cleanup()
  -- What's the meaning of the `DELETE` method? {{{
  --
  --   > The DELETE method requests that the origin server delete the resource
  --   > identified by the Request-URI.
  --
  -- Source: https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
  -- }}}
  curl.delete "http://localhost:8090"
  state.active = false
  os.execute(RESIZE_KITTY_WINDOW_CMD)
end

-- Return the buffer lines after injecting an anchor tag at the cursor line.
--
-- This tag will be used by the server to scroll the document at that position.
-- Note that this does not work when the tag (cursor) is inside a code block.
---@return string
local function get_lines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- Inject an invisible marker {{{
  --
  -- The web server will use it to  scroll the window where we've made our last
  -- edit.
  --
  -- Source:
  --    https://github.com/suan/vim-instant-markdown/pull/74#issue-37422001
  --    https://github.com/suan/instant-markdown-d/pull/26
  -- }}}
  local linenr = math.max(1, vim.fn.line "." - 5)
  lines[linenr] = lines[linenr] .. ' <a name="#marker" id="marker"></a>'
  return table.concat(lines, "\n")
end

local function toggle_preview()
  -- If there are splits in the current tab, then open the buffer in a new tab
  local autocmds = {}
  if state.active then
    cleanup()
  else
    os.execute(START_SERVER_CMD)
    vim.list_extend(autocmds, {
      {
        events = {
          "BufWrite",
          "CursorHold",
          "InsertLeave",
        },
        targets = "<buffer>",
        command = function()
          curl.put("http://localhost:8090", {
            raw_body = get_lines(),
            -- Dummy function to make the curl request asynchronous.
            callback = function() end,
          })
        end,
      },
      {
        events = "BufUnload",
        targets = "<buffer>",
        command = cleanup,
      },
    })
    state.active = true
    os.execute(HS_ACTIVATE_BROWSER_CMD)
  end
  dm.augroup("dm__markdown_previewer", autocmds)
end

-- }}}1

return { preview = toggle_preview }
