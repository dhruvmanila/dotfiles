local map = require("dm.utils").map
local opts = { silent = true, expr = true }

map("i", "<C-Space>", [[compe#complete()]], opts)
map("i", "<CR>", [[compe#confirm('<CR>')]], opts)
map("i", "<C-e>", [[compe#close('<C-e>')]], opts)
map("i", "<C-f>", [[compe#scroll({'delta': +4})]], opts)
map("i", "<C-b>", [[compe#scroll({'delta': -4})]], opts)

map({ "i", "s" }, "<Tab>", "v:lua.tab_complete()", { expr = true })
map({ "i", "s" }, "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })

require("compe").setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = "disable",
  documentation = true,

  source = {
    path = { priority = 9 },
    buffer = { menu = "[Buf]", priority = 8 },
    nvim_lsp = { priority = 10 },
    nvim_lua = { priority = 10 },
    -- vsnip = true;  -- TODO: uncomment when snippets are setup
  },
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col "." - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match "%s" then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
-- TODO: Uncomment after seting up snippets
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
    -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
    --   return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn["compe#complete"]()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
    -- elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    --   return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end
