-- To install the web server: {{{
--
--     $ brew install nodejs npm
--     $ git clone https://github.com/dhruvmanila/instant-markdown-d
--     $ npm -g install
-- }}}

local job = require 'dm.job'

-- Variables {{{1

-- Default request url.
local API_URL = 'http://localhost:8090'

-- Path to the executable
local SERVER_EXEC = 'instant-markdown-d'

-- The server can be configured via several environment variables.
-- Source: https://github.com/suan/instant-markdown-d#environment-variables
local SERVER_ENV = 'INSTANT_MARKDOWN_ALLOW_UNSAFE_CONTENT=1'

-- `stdout` and `stderr` of the server will be redirected to this file.
local SERVER_LOG_FILE = vim.env.DEBUG
    and vim.fn.stdpath 'cache' .. '/instant_markdown_d.log'
  or '/dev/null'

-- Command to start the server {{{
--                                 ┌─ do not open the browser window by default
--                                 │
--                                 │            ┌─ redirect stdout and stderr
--                                 │            │  to `SERVER_LOG_FILE`
--                                 │            │
--                                 │            │ ┌─ start the process in the background
--                                 │     ┌──────┤ │ }}}
local START_SERVER_CMD = ('%s %s --debug >%s 2>&1 &'):format(
  SERVER_ENV,
  SERVER_EXEC,
  SERVER_LOG_FILE
)

-- This script creates a split like view of the _screen_ where the left half
-- is the terminal and right half is the browser window where the file will be
-- previewed. Look at the mentioned file for more info.
--
--                                   ┌─ auto launch hammerspoon if it is not
--                                   │  currently running
--                                   │
--                                   │  ┌─ enable print mirroring from this
--                                   │  │  instance to the hammerspoon console
--                                   │  │
local HS_ACTIVATE_BROWSER_CMD = 'hs -A -P ~/.hammerspoon/preview.lua'

-- The browser will be automatically closed by the server so the only task
-- remaining is to resize the terminal window.
--
-- This requires the `allow_remote_control` and `listen_on` option to be set
-- in your kitty config.
local RESIZE_KITTY_WINDOW_CMD =
  'kitty @ --to=$KITTY_LISTEN_ON resize-os-window --action=toggle-maximized'

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
  job { cmd = 'curl', args = { '-X', 'DELETE', API_URL } }
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
  local linenr = vim.fn.line '.'
  lines[linenr] = lines[linenr] .. ' <a name="#marker" id="marker"></a>'
  return table.concat(lines, '\n')
end

local function toggle_preview()
  local id = vim.api.nvim_create_augroup('dm__markdown_previewer', {
    clear = true,
  })
  if state.active then
    cleanup()
  else
    os.execute(START_SERVER_CMD)
    vim.api.nvim_create_autocmd({ 'BufWrite', 'CursorHold', 'InsertLeave' }, {
      group = id,
      pattern = '<buffer>',
      callback = function()
        job {
          cmd = 'curl',
          args = { '-X', 'PUT', '--data-raw', get_lines(), API_URL },
        }
      end,
    })
    vim.api.nvim_create_autocmd('BufUnload', {
      group = id,
      pattern = '<buffer>',
      callback = cleanup,
    })
    state.active = true
    os.execute(HS_ACTIVATE_BROWSER_CMD)
  end
end

-- }}}1

return { preview = toggle_preview }
