-- https://github.com/simrat39/symbols-outline.nvim
local M = {}

function M.setup()
  vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false, -- experimental
    position = "right",
    keymaps = {
      close = "q",
      goto_location = "<CR>",
      focus_location = "o",
      hover_symbol = "<C-space>",
      rename_symbol = "r",
      code_actions = "a",
    },
    lsp_blacklist = {},
  }
end

function M.config()
  vim.api.nvim_set_keymap(
    "n",
    "<Leader>so",
    "<Cmd>SymbolsOutline<CR>",
    { noremap = true }
  )
end

return M
