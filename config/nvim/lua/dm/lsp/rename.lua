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
--   - `<C-l>`: clear the rename prompt
---@param bufnr number rename window buffer number
local function set_mappings(bufnr)
  local opts = { buffer = bufnr, nowait = true }
  nnoremap("<Esc>", cleanup, opts)
  inoremap("<Esc>", cleanup, opts)
  inoremap("<C-l>", function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  end, opts)
end

-- Rename prompt callback function. It receives the entered value in the prompt
-- buffer by Neovim.
---@param new_name string
local function callback(new_name)
  cleanup()
  local orig_name = vim.fn.expand "<cword>"
  if not new_name or #new_name == 0 or new_name == orig_name then
    return
  end
  local params = lsp.util.make_position_params()
  params.newName = new_name
  lsp.buf_request(0, "textDocument/rename", params)
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
    string.format("FloatBorder:%s,NormalFloat:Normal", config.border_hl)
  )

  -- To line it up with the title
  vim.fn.prompt_setprompt(bufnr, " ")
  vim.fn.prompt_setcallback(bufnr, callback)

  set_mappings(bufnr)
  cmd "startinsert!"
  api.nvim_feedkeys(orig_name, "i", true)
end

return M
