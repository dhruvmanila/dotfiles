local M = {}

local utils = require 'dm.utils'

-- Default interval to check macOS appearance (in milliseconds)
local DEFAULT_INTERVAL = 3 * 1000

local function check()
  vim.system(
    { 'defaults', 'read', '-g', 'AppleInterfaceStyle' },
    ---@param result vim.SystemCompleted
    vim.schedule_wrap(function(result)
      local appearance
      if result.code == 0 then
        appearance = vim.trim(result.stdout)
      else
        dm.log.debug('Failed to detect macOS appearance: %s (defaulting to light)', result.stderr)
        appearance = 'Light'
      end
      if appearance == 'Dark' then
        if vim.g.colors_name ~= dm.config.colorscheme.dark then
          vim.cmd.colorscheme(dm.config.colorscheme.dark)
        end
      elseif appearance == 'Light' then
        if vim.g.colors_name ~= dm.config.colorscheme.light then
          vim.cmd.colorscheme(dm.config.colorscheme.light)
        end
      else
        dm.log.warn('Unknown macOS appearance: %s', appearance)
      end
    end)
  )
end

---@type uv.uv_timer_t?
local timer

---@param interval? number in milliseconds
function M.enable(interval)
  interval = interval or DEFAULT_INTERVAL
  timer = utils.set_interval_callback(interval, check)
end

function M.disable()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

function M.toggle()
  if timer then
    M.disable()
  else
    M.enable()
  end
end

return M
