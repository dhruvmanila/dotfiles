-- Neovim UI overrides

-- Cleanup tasks performed:
--   - Exit from insert mode
--   - Delete the prompt buffer
local function input_cleanup()
  vim.cmd "stopinsert"
  vim.api.nvim_buf_delete(0, { force = true })
end

---@param opts table
---@param on_confirm fun(input?: string): nil
vim.ui.input = function(opts, on_confirm)
  vim.validate { on_confirm = { on_confirm, "function" } }
  opts = opts or {}

  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_opts = vim.lsp.util.make_floating_popup_options(40, 1, {
    border = "rounded",
  })
  local winnr = vim.api.nvim_open_win(bufnr, true, win_opts)

  vim.bo[bufnr].buftype = "prompt"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.wo[winnr].wrap = false
  vim.wo[winnr].winhl = "FloatBorder:Normal,NormalFloat:Normal"

  -- For rename request, I don't want any prompt and for others we will provide
  -- a padding between the border and prompt.
  ---@see $VIMRUNTIME/lua/vim/lsp/buf.lua:253
  vim.fn.prompt_setprompt(
    bufnr,
    vim.startswith(opts.prompt, "New Name") and " " or " " .. opts.prompt
  )
  vim.fn.prompt_setcallback(bufnr, function(new_input)
    input_cleanup()
    on_confirm(#new_input > 0 and new_input or nil)
  end)

  -- Define the required set of mappings:
  --   - `<ESC>`: exit the rename prompt
  local map_opts = { buffer = bufnr, nowait = true }
  vim.keymap.set("n", "<Esc>", input_cleanup, map_opts)
  vim.keymap.set("i", "<Esc>", input_cleanup, map_opts)

  vim.cmd "startinsert!"
  if opts.default then
    vim.api.nvim_feedkeys(opts.default, "i", true)
  end
end
