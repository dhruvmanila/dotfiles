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
}
