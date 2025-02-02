-- This module provides a way to navigate between Neovim and Kitty windows.
--
-- The implementation is done using the following kittens:
-- - `./config/kitty/navigate_kitty.py`
-- - `./config/kitty/navigate_or_pass_keys.py`
local M = {}

---@param key 'h'|'j'|'k'|'l'
---@param direction 'left'|'bottom'|'top'|'right'
local function navigate(key, direction)
  local left_win = vim.fn.winnr('1' .. key)
  if vim.fn.winnr() ~= left_win then
    dm.log.debug('Navigating to the %s neovim window', direction)
    vim.cmd.wincmd(key)
  else
    dm.log.debug('Navigating to the %s kitty window', direction)
    vim.system({ 'kitty', '@', 'kitten', 'navigate_kitty.py', direction }, function(result)
      if result.code > 0 then
        dm.log.error('Failed to navigate to the %s window: %s', direction, result.stderr)
      end
    end)
  end
end

-- Navigate to the left window which could be either a Neovim or Kitty window.
function M.left()
  navigate('h', 'left')
end

-- Navigate to the bottom window which could be either a Neovim or Kitty window.
function M.bottom()
  navigate('j', 'bottom')
end

-- Navigate to the top window which could be either a Neovim or Kitty window.
function M.top()
  navigate('k', 'top')
end

-- Navigate to the right window which could be either a Neovim or Kitty window.
function M.right()
  navigate('l', 'right')
end

return M
