local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node

-- Wrapper function around LuaSnip parse function which accepts table as the
-- `body` argument, and will concatenate it before passing to the original function.
local function parse(context, body, tab_stops, brackets)
  if type(body) == "table" then
    body = table.concat(body, "\n")
  end
  return ls.parser.parse_snippet(context, body, tab_stops, brackets)
end

-- If only one argument is passed, then return that many number of tabs,
-- otherwise return 'size' number of tabs (optional) prefixed to 'text'.
---@param text string
---@param size? number
---@return string
---@overload fun(size: number): string
local function indent(text, size)
  size = size or 1
  if type(text) == "number" then
    size = text
    text = ""
  end
  return string.rep("\t", size) .. text
end

-- Save the snippets so that the snippets which have been exited can still be
-- jumped back in.
--
-- They can be manually removed with `:LuasnipUnlinkCurrent`
ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}

ls.snippets.all = {
  s(
    { trig = "date" },
    { f(function()
      return { os.date "%Y-%m-%d" }
    end, {}), i(0) }
  ),
}

ls.snippets.lua = {
  parse(
    { trig = "fmt", dscr = "Format string" },
    'string.format("${1:formatstring}", $2)$0'
  ),

  parse(
    { trig = "req", dscr = "require a lua module" },
    'require("${1:modname: string}")'
  ),

  parse(
    { trig = "lreq", dscr = "require and store a lua module" },
    'local ${1:var} = require("${2:modname: string}")'
  ),

  parse({ trig = "augroup", dscr = "Define augroup using native function" }, {
    'dm.augroup("${1:name: string}", {',
    "\t$2",
    "})",
  }),

  s({ trig = "stylua" }, {
    t "-- stylua: ignore",
    c(1, { t "", t " start", t " end" }),
    i(0),
  }),

  -- A component to be used with 'autocmd' and 'augroup' snippets.
  -- {
  --   group = $1<string>, -- Optional node
  --   events = $2<string|string[]>,
  --   targets = $3<string|string[]>,
  --   modifiers = $4<string|string[]>, -- Optional node
  --   command = $5<string|function>,
  -- }$0
  --
  -- Optional nodes can be removed by moving to another choice.
  s({ trig = "au", dscr = "autocmd/augroup component" }, {
    t "{",
    c(1, {
      sn(
        nil,
        { t { "", indent "group = " }, t '"', i(1, "group: string"), t '",' }
      ),
      t "",
    }),
    t { "", indent "events = " },
    c(2, {
      sn(nil, { t '"', i(1, "event: string"), t '"' }),
      sn(nil, { t "{", i(1, "events: string[]"), t "}" }),
    }),
    t { ",", indent "targets = " },
    c(3, {
      sn(nil, { t '"', i(1, "target: string"), t '"' }),
      sn(nil, { t "{", i(1, "targets: string[]"), t "}" }),
    }),
    c(4, {
      sn(nil, {
        t { ",", indent 'modifiers = "' },
        i(1, "modifier"),
        t '"',
      }),
      sn(nil, {
        t { ",", indent "modifiers = {" },
        i(1, "modifiers: string[]"),
        t "}",
      }),
      t "",
    }),
    t { ",", indent "command = " },
    c(5, {
      sn(nil, { t '"', i(1, "command: string"), t '",' }),
      sn(nil, { i(1, "name: function"), t "," }),
      sn(nil, {
        t { "function()", indent(2) },
        i(1, "body"),
        t { "", indent "end," },
      }),
    }),
    t { "", "}" },
    i(0),
  }),
}
