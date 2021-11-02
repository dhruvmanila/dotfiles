---@see https://github.com/akinsho/dotfiles/tree/main/.config/nvim/lua/as/globals.lua
---@see https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals.lua

local api = vim.api

local log = require "dm.log"

-- Store all callbacks in one global table so they are able to survive
-- re-requiring this file
_NvimGlobalCallbacks = _NvimGlobalCallbacks or {}
_NvimKeymapCallbacks = _NvimKeymapCallbacks or {}

-- Create a global namespace to store callbacks, global functions, etc.
_G.dm = {
  _store = _NvimGlobalCallbacks,
  _map_store = _NvimKeymapCallbacks,
}

-- If the border key is custom, then return the respective table otherwise
-- return the string as it is.
dm.border = setmetatable({
  -- https://en.wikipedia.org/wiki/Box-drawing_character
  edge = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
}, {
  __index = function(_, key)
    return key
  end,
})

dm.icons = {
  lsp_kind = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  },
  error = "",
  warn = "",
  info = "",
  hint = "",
}

---@generic T
---@param v T
---@return T
P = function(v)
  print(vim.inspect(v))
  return v
end

-- Clear the 'require' cache and 'luacache' for the module name.
RELOAD = function(...)
  require("plenary.reload").reload_module(...)
end

-- Reload and require the given module name.
---@param name string
---@return any
R = function(name)
  RELOAD(name)
  return require(name)
end

-- Dump the contents of the given arguments.
---@vararg any
function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(table.concat(objects, "\n"))
end

do
  local output = "[timer]%s: %fms"
  local hrtime = vim.loop.hrtime
  local start = {}

  -- Simple interface for timing code chunks.
  _G.timer = {
    start = function()
      table.insert(start, hrtime())
    end,
    stop = function(info)
      print(
        output:format(
          info and " " .. info or "",
          (hrtime() - table.remove(start)) / 1e6
        )
      )
    end,
  }
end

-- Returns a function which when called will call the function `f` with the
-- given arguments.
--
-- This is just a wrapper around the provided function to be called at a later
-- point. Its main purpose is to be used in mappings where multiple keys are
-- bound to the same function with a slight modification.
---@param f function
---@return function
function _G.wrap(f, ...)
  vim.validate { f = { f, "f" } }
  local args = { ... }
  return function()
    return f(unpack(args))
  end
end

do
  local notify

  local function setup()
    notify = require "notify"
    notify.setup {
      stages = "fade",
      background_colour = "#282828",
      icons = {
        ERROR = dm.icons.error,
        WARN = dm.icons.warn,
        INFO = dm.icons.info,
        DEBUG = "",
      },
    }
  end

  ---@class NotifyOpts
  ---@field timeout number
  ---@field title string
  ---@field icon string
  ---@field on_open function
  ---@field on_close function

  local levels = vim.log.levels

  -- Default values for the notification title as per the log level.
  local default_title = {
    [levels.TRACE] = "Trace",
    [levels.DEBUG] = "Debug",
    [levels.INFO] = "Information",
    [levels.WARN] = "Warning",
    [levels.ERROR] = "Error",
  }

  -- Override the default `vim.notify` to open a floating window.
  ---@param msg string|string[]
  ---@param log_level? number|string
  ---@param opts? NotifyOpts
  vim.notify = function(msg, log_level, opts)
    -- Defer the plugin setup until the first notification call because
    -- it takes around 12ms to load.
    if not notify then
      setup()
    end
    log_level = log_level or levels.INFO
    opts = opts or {}
    opts.title = opts.title
      or (type(log_level) == "string" and log_level)
      or default_title[log_level]
    notify(msg, log_level, opts)
  end

  -- Wrapper around `vim.notify` to simplify passing the `title` value.
  --
  -- Use `vim.notify` directly to use the default `title` values.
  ---@param title string
  ---@param msg string|string[]
  ---@param log_level? number|string
  dm.notify = function(title, msg, log_level)
    vim.notify(msg, log_level, { title = title })
  end
end

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
  return api.nvim_replace_termcodes(str, true, true, true)
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
    if vim.is_callable(command) then
      local fn_id = create(command)
      command = ("lua dm._execute(%d)"):format(fn_id)
    end
    vim.cmd(
      ("autocmd %s %s %s %s %s"):format(
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
  if vim.is_callable(repl) then
    local fn_id = create(repl)
    local args = ""
    if opts.nargs then
      -- Rationale {{{
      --
      -- In case when no argument is passed for `nargs=?`, `<f-args>` expands to
      -- nothing and the function call gives us a syntax error:
      --
      --     `command_function(<fn_id>,,<q-mods>)`
      --
      -- With `<q-args>` it will be:
      --
      --     `command_function(<fn_id>, '', <q-mods>)`
      -- }}}
      args = (opts.nargs == "?" or opts.nargs <= 1) and ", <q-args>"
        or ", <f-args>"
    end
    -- Using `<q-mods>` instead of `<mods>` for the same reason as mentioned above.
    repl = ("lua dm._execute(%d%s, <q-mods>)"):format(fn_id, args)
  elseif repl_type ~= "string" then
    log.fmt_error("Unsupported repl type %s for command %s", repl_type, name)
    return
  end
  local attr = ""
  for key, val in pairs(opts) do
    val = type(val) == "boolean" and "" or "=" .. val
    attr = ("%s -%s%s"):format(attr, key, val)
  end
  vim.cmd(("command! %s %s %s"):format(attr, name, repl))
end

do
  ---@alias CaseT string|number|function

  ---@param x CaseT
  ---@return any
  local function resolve(x, ...)
    return vim.is_callable(x) and x(...) or x
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
      local msg = ("expected one of '%s', got %s"):format(
        table.concat(expected, "', '"),
        vim.inspect(value)
      )
      vim.notify(debug.traceback(msg, 2), 4)
    end
  end
end

do
  ---@alias KeymapMode
  ---| '""'  # Normal, Visual, Select and Operator-pending
  ---| '"n"' # Normal
  ---| '"v"' # Visual and Select
  ---| '"s"' # Select
  ---| '"x"' # Visual
  ---| '"o"' # Operator-pending
  ---| '"i"' # Insert
  ---| '"c"' # Command-line
  ---| '"t"' # Terminal

  -- Register the callback for the given key.
  ---@param mode KeymapMode
  ---@param key string
  ---@param callback function
  ---@param bufnr? number (optional)
  ---@return string
  local function create_keymap_entry(mode, key, callback, bufnr)
    -- Prefix it with a letter so it can be used as a dictionary key.
    local id = "k" .. mode .. key

    if bufnr then
      -- Initialize and establish cleanup.
      if not dm._map_store[bufnr] then
        dm._map_store[bufnr] = {}
        api.nvim_buf_attach(bufnr, false, {
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
    -- The key escapement logic is taken from `packer/compile`
    return id:gsub("<", "<lt>"):gsub('([\\"])', "\\%1")
  end

  -- Execute the keymap callback for the provided bufnr and id.
  ---@param bufnr? number (optional)
  ---@param id string
  ---@return any
  function dm._execute_keymap(bufnr, id)
    if bufnr and bufnr ~= vim.NIL then
      return dm._map_store[bufnr][id]()
    end
    return dm._map_store[id]()
  end

  -- Factory function to create mapper functions.
  ---@param mode KeymapMode
  ---@param defaults table
  ---@return fun(lhs: string, rhs: string|function, opts: table): nil
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
          bufnr = api.nvim_get_current_buf()
        end
        opts.buffer = nil
      end

      local rhs_type = type(rhs)
      if vim.is_callable(rhs) then
        local fn_id = create_keymap_entry(mode, lhs, rhs, bufnr)
        -- <expr> are vimscript expressions, so we will use `v:lua` to access
        -- the lua globals and execute the callback.
        if opts.expr then
          -- This is going into vimscript world so it requires `v:null` instead
          -- of the lua `nil`.
          bufnr = bufnr or "v:null"
          rhs = ('v:lua.dm._execute_keymap(%s, "%s")'):format(bufnr, fn_id)
        elseif mode == "v" or mode == "x" then
          rhs = (':<C-U>lua dm._execute_keymap(%s, "%s")<CR>'):format(
            bufnr,
            fn_id
          )
        else
          rhs = ('<Cmd>lua dm._execute_keymap(%s, "%s")<CR>'):format(
            bufnr,
            fn_id
          )
        end
      elseif rhs_type ~= "string" then
        log.fmt_error("Unsupported rhs type %s for key %s", rhs_type, lhs)
        return
      end

      if bufnr then
        api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
      else
        api.nvim_set_keymap(mode, lhs, rhs, opts)
      end
    end
  end

  -- Factory function to create unmap functions.
  ---@param mode KeymapMode
  ---@return fun(lhs: string, buffer: "true"|number): nil
  local function make_delete_mapper(mode)
    return function(lhs, buffer)
      local id = "k" .. mode .. lhs
      if buffer then
        -- We are directly using the current buffer instead of passing in the
        -- 0 because we need to clear the functions accordingly.
        if buffer == true or buffer == 0 then
          buffer = api.nvim_get_current_buf()
        end
        api.nvim_buf_del_keymap(buffer, mode, lhs)
        if dm._map_store[buffer] then
          dm._map_store[buffer][id] = nil
        end
      else
        api.nvim_del_keymap(mode, lhs)
        dm._map_store[id] = nil
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

  dm.unmap = make_delete_mapper ""
  dm.nunmap = make_delete_mapper "n"
  dm.iunmap = make_delete_mapper "i"
  dm.cunmap = make_delete_mapper "c"
  dm.vunmap = make_delete_mapper "v"
  dm.xunmap = make_delete_mapper "x"
  dm.sunmap = make_delete_mapper "s"
  dm.ounmap = make_delete_mapper "o"
  dm.tunmap = make_delete_mapper "t"
end
