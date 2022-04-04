-- Neovim UI overrides

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
    vim.api.nvim_win_close(winnr, true)
    -- After closing the window, the cursor gets moved back by 1 column. So,
    -- reset the cursor back to where it was before the window was opened.
    local position = vim.api.nvim_win_get_cursor(0)
    position[2] = position[2] + 1
    vim.api.nvim_win_set_cursor(0, position)
    on_confirm(new_input)
  end

  vim.fn.prompt_setprompt(bufnr, opts.prompt)
  -- This needs to be schedule wrapped for some reason, otherwise Neovim gets
  -- into a very weird and bad state. I was seeing text get deleted from the
  -- buffer and "NewLine" text being added to random places.
  vim.fn.prompt_setcallback(bufnr, vim.schedule_wrap(callback))

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
