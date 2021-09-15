local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local cmd = api.nvim_command
local utils = require "dm.utils"

local nnoremap = dm.nnoremap
local inoremap = dm.inoremap

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
---@see $VIMRUNTIME/lua/vim/lsp/buf.lua:251
function M.rename()
  local params = lsp.util.make_position_params()
  lsp.buf_request(0, "textDocument/prepareRename", params, function(err, result)
    if not (err or result) then
      dm.notify("LSP Rename", "Nothing to rename")
      return
    end

    -- Result can be:
    --   - Range
    --   - { range: Range, placeholder: string }
    --   - { defaultBehavior: boolean }
    --   - null
    ---@see https://microsoft.github.io/language-server-protocol/specification#textDocument_prepareRename

    local orig_name
    if result then
      orig_name = result.placeholder
      if not orig_name and result.start and result["end"] then
        local line = fn.getline(result.start.line + 1)
        orig_name = line:sub(
          result.start.character + 1,
          result["end"].character
        )
      end
    end

    -- Fallback to guessing symbol using `<cword>`.
    --
    -- This can happen if the language server does not support `prepareRename`,
    -- returns an unexpected response, or requests for "default behavior"
    if not orig_name then
      orig_name = fn.expand "<cword>"
    end

    local bufnr = api.nvim_create_buf(false, true)
    local win_opts = utils.make_floating_popup_options(40, 1, "rounded")
    local winnr = api.nvim_open_win(bufnr, true, win_opts)

    vim.bo[bufnr].buftype = "prompt"
    vim.bo[bufnr].bufhidden = "wipe"
    vim.wo[winnr].wrap = false
    vim.wo[winnr].winhl = "FloatBorder:Normal,NormalFloat:Normal"

    -- To provide a padding between the border and text.
    fn.prompt_setprompt(bufnr, " ")
    fn.prompt_setcallback(bufnr, function(new_name)
      cleanup()
      if not (new_name and #new_name > 0 and orig_name ~= new_name) then
        return
      end
      params.newName = new_name
      lsp.buf_request(0, "textDocument/rename", params)
    end)

    set_mappings(bufnr)
    cmd "startinsert!"
    api.nvim_feedkeys(orig_name, "i", true)
  end)
end

return M
