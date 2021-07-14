local imap = dm.imap
local smap = dm.smap
local inoremap = dm.inoremap

local luasnip = require "luasnip"

require("compe").setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = "disable",
  documentation = {
    border = dm.border[vim.g.border_style],
    winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  },
  source = {
    path = { priority = 9 },
    buffer = { menu = "[Buf]", priority = 8 },
    nvim_lsp = { priority = 10 },
    nvim_lua = { priority = 10 },
    luasnip = true,
  },
}

-- Convenience wrapper around `nvim_replace_termcodes()`.
--
-- Converts a string representation of a mapping's RHS (eg. "<Tab>") into an
-- internal representation (eg. "\t").
---@param str string
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- Returns true if the cursor is in leftmost column or at a whitespace
-- character, false otherwise.
---@return boolean
local check_back_space = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
end

-- Use <Tab> to either:
--   - move to next item in the completion menu
--   - jump to the next insertion node in snippets
--   - pass raw <Tab> character
--   - open completion menu
local tab = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif luasnip.expand_or_jumpable() then
    return t "<Plug>luasnip-expand-or-jump"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn["compe#complete"]()
  end
end

-- Use <S-Tab> to either:
--   - move to previous item in the completion menu
--   - jump to the previous insertion node in snippets
--   - pass raw <S-Tab> character
local shift_tab = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif luasnip.jumpable(-1) then
    return t "<Plug>luasnip-jump-prev"
  else
    return t "<S-Tab>"
  end
end

-- Use <C-e> to either:
--   - close the completion menu
--   - move to next choice for luasnip
--   - pass raw <C-e> character
local c_e = function()
  if vim.fn.pumvisible() == 1 then
    return vim.fn["compe#close"]()
  elseif luasnip.choice_active() then
    return t "<Plug>luasnip-next-choice"
  else
    return t "<C-e>"
  end
end

-- "Supertab" like functionality, where <Tab>/<S-Tab> auto-completes or moves
-- between completion menu items or jumps between insertion nodes in snippets.
--
-- This is a non-recursive mapping because the function might return '<Plug>'
-- map in case of snippets.
imap { "<Tab>", tab, expr = true }
smap { "<Tab>", tab, expr = true }
imap { "<S-Tab>", shift_tab, expr = true }
smap { "<S-Tab>", shift_tab, expr = true }

-- Similar to above where this will either close the completion menu or move
-- to the next choice for LuaSnip choice node. (:h luasnip-choicenode)
--
-- This is a non-recursive mapping because the function might return '<Plug>'
-- map in case of snippets.
imap { "<C-e>", c_e, expr = true }
smap { "<C-e>", c_e, expr = true }

-- Scrolling for the documentation window: (f)orwards and (b)ackwards
-- Alternative: `<C-f>` and `<C-d>`
inoremap { "<C-f>", "compe#scroll({'delta': +4})", expr = true }
inoremap { "<C-b>", "compe#scroll({'delta': -4})", expr = true }

inoremap { "<CR>", "compe#confirm('<CR>')", expr = true }
