local api = vim.api
local feedkeys = api.nvim_feedkeys
local escape = dm.escape
local lsp_kind = dm.icons.lsp_kind

local cmp = require "cmp"
local luasnip = require "luasnip"

local source_name = {
  buffer = "[Buf]",
  gh_issue = "[Gh]",
  luasnip = "[Snip]",
  nvim_lsp = "[LSP]",
  path = "[Path]",
}

-- Returns true if the position before the cursor (if not in the first column)
-- contains anything except for a whitespace character, false otherwise.
---@return boolean
local function has_words_before()
  local line, col = unpack(api.nvim_win_get_cursor(0))
  return col ~= 0
    and api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match "%s"
      == nil
end

-- Use `<Tab>` to either:
--   - move to next item in the completion menu
--   - jump to the next insertion node in snippets
--   - pass raw <Tab> character
---@param fallback function
local function tab(fallback)
  if cmp.visible() then
    return cmp.select_next_item()
  elseif luasnip.expand_or_jumpable() then
    return luasnip.expand_or_jump()
  elseif has_words_before() then
    return cmp.complete()
  else
    return fallback()
  end
end

-- Use `<S-Tab>` to either:
--   - move to previous item in the completion menu
--   - jump to the previous insertion node in snippets
---@param fallback function
local function shift_tab(fallback)
  if cmp.visible() then
    return cmp.select_prev_item()
  elseif luasnip.jumpable(-1) then
    return luasnip.jump(-1)
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
    -- Order of item's fields for completion menu.
    fields = { "kind", "abbr", "menu" },
    --                        ┌ `:help complete-items`
    --                        │
    format = function(entry, item)
      item.kind = lsp_kind[item.kind]
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
  -- By default, the order of the sources matter. That gives them priority.
  sources = {
    { name = "gh_issue" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" },
    {
      name = "buffer",
      opts = {
        -- Provide suggestions from all the visible buffers.
        ---@return number[]
        get_bufnrs = function()
          return vim.tbl_map(function(winid)
            return api.nvim_win_get_buf(winid)
          end, api.nvim_list_wins())
        end,
      },
      keyword_length = 4,
    },
  },
}
