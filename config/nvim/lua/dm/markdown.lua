-- To install the web server: {{{
--
--     $ brew install npm
--     $ npm -g install instant-markdown-d
-- }}}

local uv = vim.loop
local curl = require "plenary.curl"

-- Variables {{{1

local DEBUG = false

-- Notification title
local TITLE = "Instant Markdown Previewer"

-- Path to the executable
local SERVER_EXEC = "instant-markdown-d"

-- The markdown preview server can be configured via several environment variables.
-- Source: https://github.com/suan/instant-markdown-d#environment-variables
local SERVER_ENV = { "INSTANT_MARKDOWN_ALLOW_UNSAFE_CONTENT=1" }

-- This basically creates a split like view of the screen where the left half
-- is the terminal and right half is the browser window where the file will be
-- previewed. Look at the mentioned file for more info.
local HS_ACTIVATE_BROWSER_CMD = "cat ~/.hammerspoon/preview.lua | hs"

-- The browser will automatically closed by the server so the only task
-- remaining is to resize the terminal window.
--
-- This requires the `allow_remote_control` and `listen_on` option to be set
-- in your kitty config.
local RESIZE_KITTY_WINDOW_CMD =
  "kitty @ --to=$KITTY_LISTEN_ON resize-os-window --action=toggle-maximized"

-- State of the previewer.
local state = { active = false }

-- Functions {{{1

---@param initial_lines string
local function start_server(initial_lines)
  local stdin = uv.new_pipe()
  local handle, pid_or_err = uv.spawn(SERVER_EXEC, {
    -- The main purpose of passing this flag is to not open the browser window
    -- by default.
    args = { "--debug" },
    cwd = uv.cwd(),
    stdio = { stdin, nil, nil },
  }, function(code)
    -- The process is closed by sending a `DELETE` request to the server. So, we
    -- don't need to handle it ourselves.
    if DEBUG then
      dm.notify(TITLE, "Server exited with code " .. code, 1)
    end
  end)
  if not handle then
    dm.notify(TITLE, { "Failed to spawn the server:", pid_or_err }, 4)
  else
    if DEBUG then
      dm.notify(TITLE, "Server started with PID: " .. pid_or_err, 1)
    end
    stdin:write(initial_lines)
    stdin:shutdown()
  end
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
  -- Resize the terminal to half and the other half should be used to preview
  -- in the browser.
  local autocmds = {}
  if state.active then
    curl.delete "http://localhost:8090"
    state.active = false
    os.execute(RESIZE_KITTY_WINDOW_CMD)
  else
    start_server(get_lines())
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
            -- This empty function is so that the curl request is made
            -- asynchronously.
            callback = function() end,
          })
        end,
      },
      {
        events = "BufUnload",
        targets = "<buffer>",
        command = function()
          -- What's the meaning of the `DELETE` method? {{{
          --
          --   > The DELETE method requests that the origin server delete the resource
          --   > identified by the Request-URI.
          --
          -- Source: https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
          -- }}}
          curl.delete "http://localhost:8090"
        end,
      },
    })
    state.active = true
    os.execute(HS_ACTIVATE_BROWSER_CMD)
  end
  dm.augroup("dm__markdown_previewer", autocmds)
end

-- }}}1

return { preview = toggle_preview }
