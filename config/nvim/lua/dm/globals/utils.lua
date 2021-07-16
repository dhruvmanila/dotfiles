-- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config
-- Ref: https://github.com/akinsho/dotfiles/tree/main/.config/nvim/lua/as/globals

-- Store all callbacks in one global table so they are able to survive
-- re-requiring this file
_NvimGlobalCallbacks = _NvimGlobalCallbacks or {}

-- Create a global namespace to store callbacks, global functions, etc.
_G.dm = {
  _store = _NvimGlobalCallbacks,
}

local format = string.format

-- Store the given function in the global callbacks table and return its
-- unique identification string.
---@param f function
---@return string
function dm._create(f)
  vim.validate { f = { f, "f" } }
  local id = #dm._store + 1
  dm._store[id] = f
  return id
end

-- Execute the callback registered at the given id, passing the rest of the
-- arguments in the same order.
---@param id number
function dm._execute(id, ...)
  return dm._store[id](...)
end

-- Convenience wrapper around `nvim_replace_termcodes()`.
--
-- Converts a string representation of a mapping's RHS (eg. "<Tab>") into an
-- internal representation (eg. "\t").
---@param str string
---@return string
function dm.escape(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

---@class AutocmdOpts
---@field group string augroup name
---@field events string|string[] a single event or list of events
---@field targets string|string[] a single target or list of targets
---@field modifiers string|string[] a single modifier or list of modifiers (once, nested)
---@field command string|function

do
  -- Helper function to resolve autocmd options.
  ---@param opt? string|string[]
  ---@return string[]
  local function resolve(opt)
    return opt and (type(opt) == "string" and { opt } or opt) or {}
  end

  -- Lua interface to vim autocommands.
  ---@param opts AutocmdOpts
  function dm.autocmd(opts)
    local command = opts.command
    if type(command) == "function" then
      local fn_id = dm._create(command)
      command = format("lua dm._execute(%d)", fn_id)
    end
    vim.cmd(
      format(
        "autocmd %s %s %s %s %s",
        opts.group or "",
        table.concat(resolve(opts.events), ","),
        table.concat(resolve(opts.targets), ","),
        table.concat(resolve(opts.modifiers), " "),
        command
      )
    )
  end
end

-- Lua interface to vim augroup.
---@param name string group name of the given autocmds
---@param commands AutocmdOpts[]
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
--   - `attr` (string[]) (optional) list of command attributes
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

do
  ---@alias CaseT string|number|function

  ---@param x CaseT
  ---@return any
  local function resolve(x, ...)
    return type(x) == "function" and x(...) or x
  end

  -- Similar to case statement.
  ---@param value CaseT
  ---@param blocks table<CaseT, CaseT>
  ---@param err? boolean
  function dm.case(value, blocks, err)
    local expected = {}
    value = resolve(value)
    for match, block in pairs(blocks) do
      match = resolve(match, value)
      if match == "*" then
        return resolve(block, value)
      end
      table.insert(expected, match)
      if match == true or match == value then
        return resolve(block, value)
      end
    end
    if err == nil or err == true then
      local msg = string.format(
        "expected one of '%s', got %s",
        table.concat(expected, "', '"),
        vim.inspect(value)
      )
      vim.notify(debug.traceback(msg, 2), 4)
    end
  end
end

do
  ---Factory function to create mapper functions.
  ---@param mode string
  ---@param defaults table
  ---@return fun(opts: table): nil
  local function make_mapper(mode, defaults)
    return function(opts)
      -- Separate out the normal and keyword arguments from the `opts` table.
      local args, map_opts = {}, {}
      for k, v in pairs(opts) do
        if type(k) == "number" then
          args[k] = v
        else
          map_opts[k] = v
        end
      end
      local lhs = args[1]
      local rhs = args[2]
      map_opts = vim.tbl_extend("force", defaults, map_opts)
      local rhs_type = type(rhs)
      if rhs_type == "function" then
        local fn_id = dm._create(rhs)
        -- <expr> are vimscript expressions, so we will use `v:lua` to access
        -- the lua globals and execute the callback.
        if map_opts.expr then
          rhs = format("v:lua.dm._execute(%d)", fn_id)
        else
          rhs = format("<Cmd>lua dm._execute(%d)<CR>", fn_id)
        end
      elseif rhs_type ~= "string" then
        error("[mapper] Unsupported rhs type: " .. rhs_type)
      end
      if map_opts.buffer then
        local bufnr = map_opts.buffer
        if bufnr == true then
          bufnr = 0
        end
        map_opts.buffer = nil
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, map_opts)
      else
        vim.api.nvim_set_keymap(mode, lhs, rhs, map_opts)
      end
    end
  end

  local map = { noremap = false }
  local noremap = { noremap = true }

  dm.nmap = make_mapper("n", map)
  dm.imap = make_mapper("i", map)
  dm.cmap = make_mapper("c", map)
  dm.vmap = make_mapper("v", map)
  dm.xmap = make_mapper("x", map)
  dm.smap = make_mapper("s", map)
  dm.omap = make_mapper("o", map)
  dm.tmap = make_mapper("t", map)

  dm.nnoremap = make_mapper("n", noremap)
  dm.inoremap = make_mapper("i", noremap)
  dm.cnoremap = make_mapper("c", noremap)
  dm.vnoremap = make_mapper("v", noremap)
  dm.xnoremap = make_mapper("x", noremap)
  dm.snoremap = make_mapper("s", noremap)
  dm.onoremap = make_mapper("o", noremap)
  dm.tnoremap = make_mapper("t", noremap)
end
