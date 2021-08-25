local fn = vim.fn
local feedkeys = vim.api.nvim_feedkeys
local escape = dm.escape
local lsp_kind = dm.icons.lsp_kind

local cmp = require "cmp"
local luasnip = require "luasnip"

local source_name = {
  nvim_lsp = "[LSP]",
  path = "[Path]",
  luasnip = "[Snip]",
  buffer = "[Buf]",
}

-- Returns true if the cursor is in leftmost column or at a whitespace
-- character, false otherwise.
---@return boolean
local function check_back_space()
  local col = fn.col "." - 1
  return col == 0 or fn.getline("."):sub(col, col):match "%s" ~= nil
end

-- Use `<Tab>` to either:
--   - move to next item in the completion menu
--   - jump to the next insertion node in snippets
--   - pass raw <Tab> character
---@param fallback function
local function tab(fallback)
  if fn.pumvisible() == 1 then
    return feedkeys(escape "<C-n>", "n", true)
  elseif luasnip.expand_or_jumpable() then
    return feedkeys(escape "<Plug>luasnip-expand-or-jump", "", true)
  elseif check_back_space() then
    return feedkeys(escape "<Tab>", "n", true)
  else
    return fallback()
  end
end

-- Use `<S-Tab>` to either:
--   - move to previous item in the completion menu
--   - jump to the previous insertion node in snippets
---@param fallback function
local function shift_tab(fallback)
  if fn.pumvisible() == 1 then
    return feedkeys(escape "<C-p>", "n", true)
  elseif luasnip.jumpable(-1) then
    return feedkeys(escape "<Plug>luasnip-jump-prev", "", true)
  else
    return fallback()
  end
end

-- Use `<C-e>` to either:
--   - close the completion menu and go back to the originally typed text
--   - move to the next node of a ChoiceNode in luasnip
---@param fallback function
local function c_e(fallback)
  if cmp.abort() then
    return
  elseif luasnip.choice_active() then
    return feedkeys(escape "<Plug>luasnip-next-choice", "", true)
  else
    return fallback()
  end
end

cmp.setup {
  confirmation = {
    default_behavior = cmp.ConfirmBehavior.Replace,
  },
  documentation = {
    border = dm.border[vim.g.border_style],
    winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
  },
  formatting = {
    --                        ┌ `:help complete-items`
    --                        │
    format = function(entry, item)
      item.kind = ("%s %s"):format(lsp_kind[item.kind], item.kind)
      item.menu = source_name[entry.source.name]
      return item
    end,
  },
  mapping = {
    ["<Tab>"] = cmp.mapping(tab, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(shift_tab, { "i", "s" }),
    ["<C-e>"] = cmp.mapping(c_e, { "i", "s" }),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<CR>"] = cmp.mapping.confirm(),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = {
    { name = "buffer" },
    { name = "luasnip" },
    { name = "nvim_lsp" },
    { name = "path" },
  },
}
