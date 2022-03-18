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

-- A tiny function to better sort completion items that start with one or more
-- underscore characters.
--
-- In Python, items that start with one or more underscores should be at the end
-- of the completion suggestion.
---@see https://github.com/lukas-reineke/cmp-under-comparator
---@return boolean
cmp.config.compare.underscore = function(entry1, entry2)
  -- These represents the number of underscore characters at the start of the
  -- completion items.
  local _, entry1_under = entry1.completion_item.label:find "^_+"
  local _, entry2_under = entry2.completion_item.label:find "^_+"
  entry1_under = entry1_under or 0
  entry2_under = entry2_under or 0
  return entry1_under < entry2_under
end

-- This function will either:
--   - move to next item in the completion menu
--   - jump to the next insertion node in snippets
--   - pass raw <Tab> character
---@param fallback function
local function next(fallback)
  if cmp.visible() then
    return cmp.select_next_item()
  elseif luasnip.expand_or_jumpable() then
    return luasnip.expand_or_jump()
  else
    return fallback()
  end
end

-- This function will either:
--   - move to previous item in the completion menu
--   - jump to the previous insertion node in snippets
---@param fallback function
local function prev(fallback)
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
    ["<C-n>"] = cmp.mapping(next, { "i", "s" }),
    ["<C-p>"] = cmp.mapping(prev, { "i", "s" }),
    ["<C-e>"] = cmp.mapping(c_e, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<CR>"] = cmp.mapping.confirm(),

    -- Disable some default mappings which comes in the way on the command-line.
    -- This is most likely temporary as I haven't yet experimented with the
    -- command-line completion feature.
    ["<Tab>"] = cmp.config.disable,
    ["<S-Tab>"] = cmp.config.disable,
    ["<C-y>"] = cmp.config.disable,
    ["<Up>"] = cmp.config.disable,
    ["<Down>"] = cmp.config.disable,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.underscore,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  -- By default, the order of the sources matter. That gives them priority.
  sources = {
    { name = "gh_issue" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" },
    {
      name = "buffer",
      options = {
        -- Provide suggestions from all the visible buffers.
        ---@return number[]
        get_bufnrs = function()
          local bufnrs = {}
          for _, winid in ipairs(api.nvim_list_wins()) do
            local bufnr = api.nvim_win_get_buf(winid)
            if api.nvim_buf_get_option(bufnr, "filetype") ~= "terminal" then
              bufnrs[#bufnrs + 1] = bufnr
            end
          end
          return bufnrs
        end,
      },
      keyword_length = 4,
    },
    { name = "emoji" },
  },
}