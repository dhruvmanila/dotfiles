local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

-- Wrapper function around LuaSnip parse function which accepts table as the
-- `body` argument, and will concatenate it before passing to the original function.
local function parse(context, body, tab_stops, brackets)
  if type(body) == 'table' then
    body = table.concat(body, '\n')
  end
  return ls.parser.parse_snippet(context, body, tab_stops, brackets)
end

-- Save the snippets so that the snippets which have been exited can still be
-- jumped back in.
--
-- They can be manually removed with `:LuasnipUnlinkCurrent`
ls.config.set_config {
  history = true,
  updateevents = 'TextChanged,TextChangedI',
}

ls.snippets.all = { -- {{{1
  s({ trig = 'todo', dscr = 'Insert TODO comment with username' }, {
    f(function()
      return vim.bo.commentstring:gsub('%%s', 'TODO(dhruvmanila): ')
    end, {}),
  }),

  s({ trig = 'date', dscr = "today's date in YYYY-mm-dd format" }, {
    f(function()
      return { os.date '%Y-%m-%d' }
    end, {}),
    i(0),
  }),
}

ls.snippets.go = { -- {{{1
  s({ trig = 'main', dscr = 'main function' }, {
    t { 'func main() {', '\t' },
    i(0),
    t { '', '}' },
  }),

  -- #1:
  --     if err != nil {
  --         return nil, err
  --     }
  --
  -- #2:
  --     if err != nil {
  --         return err
  --     }
  s({ trig = 'iferr', dscr = 'if err is not nil block' }, {
    t { 'if err != nil {', '\treturn ' },
    c(1, {
      sn(nil, { i(1, 'nil'), t ', err' }),
      t 'err',
    }),
    t { '', '}' },
  }),
}

ls.snippets.lua = { -- {{{1
  parse(
    { trig = 'fmt', dscr = 'Format string' },
    'string.format("${1:formatstring}", $2)$0'
  ),

  parse(
    { trig = 'req', dscr = 'require a lua module' },
    'require("${1:modname: string}")'
  ),

  parse(
    { trig = 'lreq', dscr = 'require and store a lua module' },
    'local ${1:var} = require("${2:modname: string}")'
  ),

  s({ trig = 'ignore' }, {
    t '-- stylua: ignore',
    c(1, { t '', t ' start', t ' end' }),
    i(0),
  }),
}

ls.snippets.python = { -- {{{1
  s({ trig = 'ifmain', dscr = 'if __name__ == "__main__":' }, {
    t { 'if __name__ == "__main__":', '\t' },
    i(1, 'pass'),
  }),
}
