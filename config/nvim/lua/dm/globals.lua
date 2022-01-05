---@see https://github.com/akinsho/dotfiles/tree/main/.config/nvim/lua/as/globals.lua
---@see https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals.lua

local api = vim.api

-- Store all callbacks in one global table so they are able to survive
-- re-requiring this file
_NvimGlobalCallbacks = _NvimGlobalCallbacks or {}

-- Create a global namespace to store callbacks, global functions, etc.
_G.dm = {
  _store = _NvimGlobalCallbacks,
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

-- Return a new function which when called will behave like func called with
-- the arguments args. If more arguments are supplied to the call, they are
-- appended to args.
--
-- It is used for partial function application which "freezes" some portion of
-- a function's arguments resulting in a new object with a simplified
-- signature.
--
-- ```lua
-- local hello = partial(function(a, b, c)
--   print(a, b, c)
-- end, "hello")
--
-- hello("world")                    -- output: hello world nil
-- hello("world", "cool")            -- output: hello world cool
-- hello("world", "cool", "ignored") -- output: hello world cool
-- ```
---@param func function
---@param ... any
---@return fun(...): any
function _G.partial(func, ...)
  vim.validate { func = { func, "function" } }
  local args = { ... }
  return function(...)
    vim.list_extend(args, { ... })
    return func(unpack(args))
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

do
  ---Factory function to generate mapper functions.
  ---@param mode string
  ---@param defaults table
  ---@return fun(lhs: string, rhs: string, opts: table)
  local function make_mapper(mode, defaults)
    defaults = defaults or {}
    return function(lhs, rhs, opts)
      opts = opts or {}
      opts = vim.tbl_extend("force", defaults, opts)

      if type(rhs) == "function" then
        opts.callback = rhs
        rhs = ""
      end

      if opts.buffer then
        local bufnr = opts.buffer
        if bufnr == true then
          bufnr = api.nvim_get_current_buf()
        end
        opts.buffer = nil
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
      else
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
      end
    end
  end

  ---Factory function to generate unmap functions.
  ---@param mode string
  ---@return fun(lhs: string, buffer?: number)
  local function make_delete_mapper(mode)
    return function(lhs, buffer)
      if buffer then
        vim.api.nvim_buf_del_keymap(buffer, mode, lhs)
      else
        vim.api.nvim_del_keymap(mode, lhs)
      end
    end
  end

  dm.map = make_mapper ""
  dm.nmap = make_mapper "n"
  dm.imap = make_mapper "i"
  dm.cmap = make_mapper "c"
  dm.vmap = make_mapper "v"
  dm.xmap = make_mapper "x"
  dm.smap = make_mapper "s"
  dm.omap = make_mapper "o"
  dm.tmap = make_mapper "t"

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
