local api = vim.api
local lsp = vim.lsp
local cmd = api.nvim_command
local utils = require "dm.utils"

local nnoremap = dm.nnoremap
local inoremap = dm.inoremap

local config = {
  width = 40,
  height = 1,
  border_hl = "Normal",
}

local M = {}

-- Cleanup tasks performed:
--   - Exit from insert mode
--   - Delete the prompt buffer
local function cleanup()
  cmd "stopinsert"
  api.nvim_buf_delete(0, { force = true })
end

-- Define the required set of mappings:
--   - `<ESC>`: exit the rename prompt
---@param bufnr number rename window buffer number
local function set_mappings(bufnr)
  local opts = { buffer = bufnr, nowait = true }
  nnoremap("<Esc>", cleanup, opts)
  inoremap("<Esc>", cleanup, opts)
end

-- Entrypoint to rename the current word at cursor. The current word will be set
-- in the prompt buffer.
function M.rename()
  local orig_name = vim.fn.expand "<cword>"
  local bufnr = api.nvim_create_buf(false, true)
  local win_opts = utils.make_floating_popup_options(
    config.width,
    config.height,
    "rounded"
  )
  local winnr = api.nvim_open_win(bufnr, true, win_opts)

  api.nvim_buf_set_option(bufnr, "buftype", "prompt")
  api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  api.nvim_win_set_option(winnr, "wrap", false)
  api.nvim_win_set_option(
    winnr,
    "winhl",
    ("FloatBorder:%s,NormalFloat:Normal"):format(config.border_hl)
  )

  -- To provide a padding between the border and text.
  vim.fn.prompt_setprompt(bufnr, " ")
  vim.fn.prompt_setcallback(bufnr, function(new_name)
    cleanup()
    if orig_name == new_name then
      return
    end
    lsp.buf.rename(new_name)
  end)

  set_mappings(bufnr)
  cmd "startinsert!"
  api.nvim_feedkeys(orig_name, "i", true)
end

return M
