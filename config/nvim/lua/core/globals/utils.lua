-- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config
-- Ref: https://github.com/akinsho/dotfiles/tree/main/.config/nvim/lua/as/globals
-- TODO: remove this once upstream got the feature

-- Store all callbacks in one global table so they are able to survive
-- re-requiring this file
_NvimGlobalCallbacks = _NvimGlobalCallbacks or {}

-- Create a global namespace to store callbacks, global functions, etc.
-- TODO: can we use 'nvim', 'g', 'neovim' or something similar to neovim itself?
_G.dm = {
  _store = _NvimGlobalCallbacks or {},
}

local api = vim.api
local format = string.format

-- Store the given function in the global callbacks table and return its
-- reference id
---@param f function
---@return number
function dm._create(f)
  table.insert(dm._store, f)
  return #dm._store
end

-- Execute the callback registered at the given id, passing the rest of the
-- arguments in the same order.
---@param id number
function dm._execute(id, ...)
  dm._store[id](...)
end

-- Lua interface to vim autocommands.
-- `opts` table can contain the following keys:
--   - `group` (string) (optional) augroup name
--   - `events` (string[]) array of events
--   - `targets` (string[]) array of target patterns
--   - `modifiers` (string[]) array of modifiers (++once, ++nested)
--   - `command` (string|function) command to execute
---@param opts table
function dm.autocmd(opts)
  local command = opts.command
  if type(command) == "function" then
    local fn_id = dm._create(command)
    command = format("lua dm._execute(%d)", fn_id)
  end
  vim.cmd(format(
    "autocmd %s %s %s %s %s",
    opts.group or "",
    table.concat(opts.events, ","),
    table.concat(opts.targets or {}, ","),
    table.concat(opts.modifiers or {}, " "),
    command
  ))
end

-- Lua interface to vim augroup.
---@param name string group name of the given commands
---@param commands table ref: dm.autocmd
function dm.augroup(name, commands)
  vim.cmd("augroup " .. name)
  vim.cmd("autocmd!")
  for _, c in ipairs(commands) do
    dm.autocmd(c)
  end
  vim.cmd("augroup END")
end

-- Lua interface to vim command.
-- `opts` table can contain the following keys:
--   - [1] (string) name of the command
--   - [2] (string|function) rhs part of the command
--   - `nargs` (number) (default: 0) nargs attribute value
--   - `attr` (string[]) (optional) list or command attributes
--     (-bang, -complete, etc)
---@param opts table
function dm.command(opts)
  local nargs = opts.nargs or 0
  local name = opts[1]
  local rhs = opts[2]
  local attr = (opts.attr and type(opts.attr) == "table")
      and table.concat(opts.attr, ",")
    or ""

  if type(rhs) == "function" then
    local fn_id = dm._create(rhs)
    rhs = format(
      "lua dm._execute(%d%s)",
      fn_id,
      nargs > 0 and ", <f-args>" or ""
    )
  end

  vim.cmd(format("command! -nargs=%d %s %s %s", nargs, attr, name, rhs))
end

-- Helper function to set the neovim options until #13479 merges. This will
-- make sure each option is set to the respective scope.
dm.opt = setmetatable({}, {
  __index = vim.o,
  __newindex = function(_, key, value)
    vim.o[key] = value
    local scope = api.nvim_get_option_info(key).scope
    if scope == "win" then
      vim.wo[key] = value
    elseif scope == "buf" then
      vim.bo[key] = value
    end
  end,
})
