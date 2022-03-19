-- Neovim UI overrides

-- Cleanup tasks performed:
--   - Exit from insert mode
--   - Delete the prompt buffer
local function input_cleanup()
  vim.cmd 'stopinsert'
  vim.api.nvim_buf_delete(0, { force = true })
end

---@param opts table
---@param on_confirm fun(input?: string): nil
vim.ui.input = function(opts, on_confirm)
  vim.validate { on_confirm = { on_confirm, 'function' } }

  opts = opts or {}
  -- Padding between left border and the prompt text.
  opts.prompt = ' ' .. (opts.prompt or '')
  opts.default = opts.default or ''

  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_opts = vim.lsp.util.make_floating_popup_options(
    #opts.prompt + #opts.default + 20,
    1,
    { border = 'rounded' }
  )
  local winnr = vim.api.nvim_open_win(bufnr, true, win_opts)

  vim.bo[bufnr].buftype = 'prompt'
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.wo[winnr].wrap = false
  vim.wo[winnr].winhl = 'FloatBorder:Normal,NormalFloat:Normal'

  -- Callback function to call once the user confirms or abort the input.
  ---@param new_input string|nil
  local function callback(new_input)
    input_cleanup()
    on_confirm(new_input)
  end

  vim.fn.prompt_setprompt(bufnr, opts.prompt)
  vim.fn.prompt_setcallback(bufnr, callback)

  -- Define the required set of mappings:
  --   - `<ESC>`: exit the rename prompt
  local map_opts = { buffer = bufnr, nowait = true }
  vim.keymap.set('n', '<Esc>', callback, map_opts)
  vim.keymap.set('i', '<Esc>', callback, map_opts)

  vim.cmd 'startinsert!'
  if opts.default ~= '' then
    vim.api.nvim_feedkeys(opts.default, 'i', true)
  end
end
