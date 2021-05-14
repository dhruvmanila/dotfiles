local api = vim.api
local lsp = vim.lsp
local icons = require("core.icons")
local utils = require("core.utils")

local M = {}
local code_action = {}

-- Define the required set of mappings:
--   - `number`: execute the respective code action "number"
--   - `<CR>`: execute the code action under the cursor
--   - `q`: quit the code action window
---@param bufnr number
---@param winnr number
local function set_mappings(bufnr, winnr)
  local opts = { noremap = true, silent = true }
  local nowait_opts = { noremap = true, silent = true, nowait = true }
  for index = 1, #code_action.actions do
    local action_fn = string.format(
      "<Cmd>lua require('plugin.lsp.code_action').do_code_action(%d)<CR>",
      index
    )
    api.nvim_buf_set_keymap(bufnr, "n", tostring(index), action_fn, opts)
  end

  local action_fn =
    "<Cmd>lua require('plugin.lsp.code_action').do_code_action()<CR>"
  api.nvim_buf_set_keymap(bufnr, "n", "<CR>", action_fn, nowait_opts)

  local close_fn = string.format(
    "<Cmd>lua vim.api.nvim_win_close(%d, true)<CR>",
    winnr
  )
  api.nvim_buf_set_keymap(bufnr, "n", "q", close_fn, nowait_opts)
end

-- Execute the given "choice" code action. If choice is `nil`, then execute
-- the code action under the cursor.
---@param choice number|nil
function M.do_code_action(choice)
  choice = choice or tonumber(vim.fn.expand("<cword>"))
  local action_chosen = code_action.actions[choice]
  api.nvim_win_close(0, true)

  -- textDocument/codeAction can return either Command[] or CodeAction[].
  -- If it is a CodeAction, it can have either an edit, a command or both.
  -- Edits should be executed first
  if action_chosen.edit or type(action_chosen.command) == "table" then
    if action_chosen.edit then
      lsp.util.apply_workspace_edit(action_chosen.edit)
    end
    if type(action_chosen.command) == "table" then
      lsp.buf.execute_command(action_chosen.command)
    end
  else
    lsp.buf.execute_command(action_chosen)
  end
  code_action.actions = {}
end

-- Main handler for the code action response from the language server.
function M.handler(_, _, response)
  if response == nil or vim.tbl_isempty(response) then
    print("[LSP] No code actions available")
    return
  end

  code_action.actions = response
  local action_lines = {}
  local longest_line = 0
  for index, action in ipairs(response) do
    local title = action.title:gsub("\r\n", "\\r\\n"):gsub("\n", "\\n")
    local pad = index < 10 and "  " or " "
    local line = string.format("[%d]%s%s", index, pad, title)
    table.insert(action_lines, line)
    longest_line = math.max(longest_line, api.nvim_strwidth(line))
  end

  local winnr, bufnr = utils.open_bordered_window({
    width = longest_line,
    height = 2 + #action_lines, -- header + separator + content
    border = icons.border.edge,
  })

  local title = string.format(" %s Code Actions:", icons.icons.lightbulb)
  utils.append(bufnr, { title }, "YellowBold")
  utils.append(bufnr, { string.rep("─", longest_line) }, "Grey")
  -- Number of rows before the code action content
  local current_row = 2

  for _, line in ipairs(action_lines) do
    utils.append(bufnr, { line })
    local _, last = string.find(line, "%d+")
    api.nvim_buf_add_highlight(bufnr, -1, "Grey", current_row, 0, 1) -- [
    api.nvim_buf_add_highlight(bufnr, -1, "Red", current_row, 1, last) -- 1
    api.nvim_buf_add_highlight(bufnr, -1, "Grey", current_row, last, last + 1) -- ]
    current_row = current_row + 1
  end
  -- Remove the last blank line
  api.nvim_buf_set_lines(bufnr, -2, -1, false, {})

  -- row and col are (1, 0)-indexed
  code_action.firstline = 3
  code_action.lastline = current_row
  code_action.fixed_column = 1
  code_action.newline = code_action.firstline

  api.nvim_buf_set_option(bufnr, "modifiable", false)
  api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  api.nvim_buf_set_option(bufnr, "matchpairs", "")

  api.nvim_win_set_cursor(
    winnr,
    { code_action.firstline, code_action.fixed_column }
  )
  set_mappings(bufnr, winnr)

  dm.autocmd({
    events = { "CursorMoved" },
    targets = { string.format("<buffer=%s>", bufnr) },
    command = function()
      require("core.utils").fixed_column_movement(code_action)
    end,
  })
end

-- For debugging purposes.
M._code_action = code_action

return M
