local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node

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

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}

ls.snippets.lua = {
  -- string.format("$1", $2)$0
  s(
    { trig = "format", dscr = "Format string" },
    { t 'string.format("', i(1, "formatstring"), t '", ', i(2), t ")", i(0) }
  ),

  -- require("$1")$0
  s(
    { trig = "req", dscr = "require a lua module" },
    { t 'require("', i(1, "modname: string"), t '")' }
  ),

  -- A component to be used with 'autocmd' and 'augroup' snippets.
  -- {
  --   group = $1<string>,               TODO
  --   events = $2<string|string[]>,
  --   targets = $3<string|string[]>,
  --   modifiers = $4<string|string[]>,  TODO
  --   command = $5<string|function>,
  -- }$0
  s({ trig = "au", dscr = "autocmd/augroup component" }, {
    t { "{", indent "events = " },
    c(1, {
      sn(nil, { t '"', i(1, "event: string"), t '"' }),
      sn(nil, { t "{", i(1, "events: string[]"), t "}" }),
    }),
    t { ",", indent "targets = " },
    c(2, {
      sn(nil, { t '"', i(1, "target: string"), t '"' }),
      sn(nil, { t "{", i(1, "targets: string[]"), t "}" }),
    }),
    t { ",", indent "command = " },
    c(3, {
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

  -- dm.autocmd($0)
  s({ trig = "autocmd", dscr = "Define autocmd using native function" }, {
    t "dm.autocmd ",
    i(0),
  }),

  -- dm.augroup($1<string>, {
  --   $2
  -- }$0
  s({ trig = "augroup", dscr = "Define augroup using native function" }, {
    t 'dm.augroup("',
    i(1, "name: string"),
    t { '", {', indent(1) },
    i(2),
    t { "", "})" },
    i(0),
  }),
}
