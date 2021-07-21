-- Inspired by @tjdevries' astraunauta.nvim/ @TimUntersberger's config
-- Ref: https://github.com/akinsho/dotfiles/tree/main/.config/nvim/lua/as/globals.lua

-- Store all callbacks in one global table so they are able to survive
-- re-requiring this file
_NvimGlobalCallbacks = _NvimGlobalCallbacks or {}
_NvimKeymapCallbacks = _NvimKeymapCallbacks or {}

-- Create a global namespace to store callbacks, global functions, etc.
_G.dm = {
  _store = _NvimGlobalCallbacks,
  _map_store = _NvimKeymapCallbacks,
}

local format = string.format

-- Store the given function in the global callbacks table and return its
-- unique identification string.
---@param f function
---@return string
local function create(f)
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
      local fn_id = create(command)
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

---@class CommandOpts
---@field addr string
---@field bang boolean
---@field bar boolean
---@field buffer boolean
---@field complete string
---@field count number|boolean
---@field nargs number|string|boolean
---@field range number|string|boolean
---@field register boolean

-- NOTE: For 'complete', if the user function is in lua, it should be added to
-- the global namespace 'dm' and passed in as a viml expression using `v:lua`.
-- An example can be found in the session (`dm.session`) module.

-- Lua interface to vim command.
---@param name string
---@param repl string|function
---@param opts? CommandOpts
function dm.command(name, repl, opts)
  opts = opts or {}
  local repl_type = type(repl)
  if repl_type == "function" then
    local fn_id = create(repl)
    local fargs = ""
    if opts.nargs and (type(opts.nargs) == "string" or opts.nargs > 0) then
      fargs = ", <f-args>"
    end
    repl = format("lua dm._execute(%d%s)", fn_id, fargs)
  elseif repl_type ~= "string" then
    error("[command] Unsupported repl type: " .. repl_type)
  end
  local attr = ""
  for key, val in pairs(opts) do
    val = type(val) == "boolean" and "" or "=" .. val
    attr = format("%s -%s%s", attr, key, val)
  end
  vim.cmd(format("command! %s %s %s", attr, name, repl))
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
  -- Register the callback for the given key.
  ---@param mode string
  ---@param key string
  ---@param callback function
  ---@param bufnr? number
  ---@return string
  local function create_keymap_entry(mode, key, callback, bufnr)
    -- Prefix it with a letter so it can be used as a dictionary key.
    local id = "k" .. mode .. key
    if bufnr then
      -- Initialize and establish cleanup.
      if not dm._map_store[bufnr] then
        dm._map_store[bufnr] = {}
        vim.api.nvim_buf_attach(bufnr, false, {
          on_detach = function()
            dm._map_store[bufnr] = nil
          end,
        })
      end
      dm._map_store[bufnr][id] = callback
    else
      dm._map_store[id] = callback
    end
    -- The ID should be escaped only for creating the keymap itself and not
    -- when using it as the key to store the callback.
    -- The key escapement logic is taken from packer/compile.lua
    return id:gsub("<", "<lt>"):gsub('([\\"])', "\\%1")
  end

  -- Execute the keymap callback at the provided bufnr and id.
  ---@param bufnr? number
  ---@param id string
  ---@return any
  function dm._execute_keymap(bufnr, id)
    if bufnr and bufnr ~= vim.NIL then
      return dm._map_store[bufnr][id]()
    end
    return dm._map_store[id]()
  end

  ---Factory function to create mapper functions.
  ---@param mode string
  ---@param defaults table
  ---@return fun(opts: table): nil
  local function make_mapper(mode, defaults)
    return function(lhs, rhs, opts)
      opts = opts or {}
      opts = vim.tbl_extend("force", defaults, opts)
      local bufnr
      if opts.buffer then
        bufnr = opts.buffer
        -- We are directly using the current buffer instead of passing in the
        -- 0 because we need to store it accordingly.
        if bufnr == true or bufnr == 0 then
          bufnr = vim.api.nvim_get_current_buf()
        end
        opts.buffer = nil
      end
      local rhs_type = type(rhs)
      if rhs_type == "function" then
        local fn_id = create_keymap_entry(mode, lhs, rhs, bufnr)
        -- <expr> are vimscript expressions, so we will use `v:lua` to access
        -- the lua globals and execute the callback.
        if opts.expr then
          -- This is going into vimscript world so it requires `v:null` instead
          -- of the lua `null`.
          rhs = format(
            'v:lua.dm._execute_keymap(%s, "%s")',
            bufnr or "v:null",
            fn_id
          )
        else
          rhs = format(
            '<Cmd>lua dm._execute_keymap(%s, "%s")<CR>',
            bufnr,
            fn_id
          )
        end
      elseif rhs_type ~= "string" then
        error("[mapper] Unsupported rhs type: " .. rhs_type)
      end
      if bufnr then
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
      else
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
      end
    end
  end

  local map = { noremap = false }
  dm.map = make_mapper("", map)
  dm.nmap = make_mapper("n", map)
  dm.imap = make_mapper("i", map)
  dm.cmap = make_mapper("c", map)
  dm.vmap = make_mapper("v", map)
  dm.xmap = make_mapper("x", map)
  dm.smap = make_mapper("s", map)
  dm.omap = make_mapper("o", map)
  dm.tmap = make_mapper("t", map)

  local noremap = { noremap = true }
  dm.noremap = make_mapper("", noremap)
  dm.nnoremap = make_mapper("n", noremap)
  dm.inoremap = make_mapper("i", noremap)
  dm.cnoremap = make_mapper("c", noremap)
  dm.vnoremap = make_mapper("v", noremap)
  dm.xnoremap = make_mapper("x", noremap)
  dm.snoremap = make_mapper("s", noremap)
  dm.onoremap = make_mapper("o", noremap)
  dm.tnoremap = make_mapper("t", noremap)
end
