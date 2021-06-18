-- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config
-- Ref: https://github.com/akinsho/dotfiles/tree/main/.config/nvim/lua/as/globals
-- TODO: remove this once upstream got the feature

-- Store all callbacks in one global table so they are able to survive
-- re-requiring this file
_NvimGlobalCallbacks = _NvimGlobalCallbacks or {}

-- Create a global namespace to store callbacks, global functions, etc.
-- TODO: can we use 'nvim', 'g', 'neovim' or something similar to neovim itself?
_G.dm = {
  _store = _NvimGlobalCallbacks,
}

local format = string.format

-- Create a unique identification string readable by human for the given
-- function. This create a string of the following format:
--        "<source>_<name>_<linedefined>"
---@param f function
---@return string
---@see https://www.lua.org/pil/23.1.html
local function create_id(f)
  local info = debug.getinfo(f, "Sn") -- Source and name related information
  if not info then
    return
  end
  local source = info.source
    :gsub(".*/lua/(.*)", "%1") -- path from "../lua/" module
    :gsub("/", ".") -- replace "/" with "."
    :gsub("%.lua$", "") -- remove the ".lua" extension
  local name = info.name and "_" .. info.name or ""
  local linedefined = "_" .. info.linedefined
  return format("%s%s%s", source, name, linedefined)
end

-- Store the given function in the global callbacks table and return its
-- unique identification string.
---@param f function
---@return string
function dm._create(f)
  vim.validate { f = { f, "f" } }
  local id = create_id(f)
  if not id or id == "" then
    id = tostring(vim.tbl_count(dm._store) + 1)
  end
  dm._store[id] = f
  return id
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
    command = format("lua dm._execute('%s')", fn_id)
  end
  vim.cmd(
    format(
      "autocmd %s %s %s %s %s",
      opts.group or "",
      table.concat(opts.events, ","),
      table.concat(opts.targets or {}, ","),
      table.concat(opts.modifiers or {}, " "),
      command
    )
  )
end

-- Lua interface to vim augroup.
---@param name string group name of the given commands
---@param commands table ref: dm.autocmd
function dm.augroup(name, commands)
  vim.cmd("augroup " .. name)
  vim.cmd "autocmd!"
  for _, c in ipairs(commands) do
    dm.autocmd(c)
  end
  vim.cmd "augroup END"
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
      "lua dm._execute('%s'%s)",
      fn_id,
      nargs > 0 and ", <f-args>" or ""
    )
  end

  vim.cmd(format("command! -nargs=%d %s %s %s", nargs, attr, name, rhs))
end

-- Similar to case statement.
---@alias CaseT string|number|function
---@param value CaseT
---@param blocks table<CaseT, CaseT>
---@param err? boolean
function dm.case(value, blocks, err)
  local expected = {}
  value = type(value) == "function" and value() or value
  for match, block in pairs(blocks) do
    match = type(match) == "function" and match(value) or match
    table.insert(expected, match)
    if match == true or match == value then
      return type(block) == "function" and block(value) or block
    end
  end
  local default = blocks["*"]
  if default then
    return type(default) == "function" and default(value) or default
  end
  if err == nil or err == true then
    local msg = string.format(
      "expected one of '%s', got %s (%s)",
      table.concat(expected, "', '"),
      vim.inspect(value),
      type(value)
    )
    error(debug.traceback(msg, 2), 2)
  end
end
