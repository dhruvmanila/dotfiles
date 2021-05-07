local api = vim.api
local icons = require('core.icons').icons

local M = {}
local actions = {}

local offset = {
  NW = {1, 0},
  NE = {1, 1},
  SW = {-2, 0},
  SE = {-2, 1},
}

local function set_mappings(bufnr, winnr, total)
  local opts = {noremap = true, silent = true, nowait = true}
  for index = 1, total do
    api.nvim_buf_set_keymap(
      bufnr, 'n', tostring(index),
      '<Cmd>lua require("plugin.lsp.handlers.code_action").do_code_action(' .. index .. ')<CR>', opts
    )
  end

  api.nvim_buf_set_keymap(
    bufnr, 'n', 'q', '<Cmd>lua vim.api.nvim_win_close(' .. winnr .. ', true)<CR>', opts
  )
end

function M.do_code_action(choice)
  local action_chosen = actions[choice]
  api.nvim_win_close(0, true)

  -- textDocument/codeAction can return either Command[] or CodeAction[].
  -- If it is a CodeAction, it can have either an edit, a command or both.
  -- Edits should be executed first
  if action_chosen.edit or type(action_chosen.command) == "table" then
    if action_chosen.edit then
      vim.lsp.util.apply_workspace_edit(action_chosen.edit)
    end
    if type(action_chosen.command) == "table" then
      vim.lsp.buf.execute_command(action_chosen.command)
    end
  else
    vim.lsp.buf.execute_command(action_chosen)
  end
  actions = {}
end

function M.code_action(_, _, response)
  if response == nil or vim.tbl_isempty(response) then
    print("[LSP] No code actions available")
    return
  end

  actions = response
  local row = 0
  local bufnr = api.nvim_create_buf(false, true)
  local title = ' ' .. icons.lightbulb .. ' Code Actions:'
  api.nvim_buf_set_lines(bufnr, row, -1, false, {title})
  api.nvim_buf_add_highlight(bufnr, -1, 'YellowBold', row, 0, -1)
  row = row + 1

  local contents = {}
  local longest_line = 0
  for index, action in ipairs(response) do
    table.insert(contents, string.format('[%d] %s', index, action.title))
    longest_line = math.max(longest_line, api.nvim_strwidth(action.title) + 4)
  end

  api.nvim_buf_set_lines(bufnr, row, -1, false, {string.rep('─', longest_line)})
  api.nvim_buf_add_highlight(bufnr, -1, 'Grey', row, 0, -1)
  row = row + 1

  for _, line in ipairs(contents) do
    api.nvim_buf_set_lines(bufnr, row, -1, false, {line})
    api.nvim_buf_add_highlight(bufnr, -1, 'Grey', row, 0, 1)  -- [
    api.nvim_buf_add_highlight(bufnr, -1, 'Red', row, 1, 2)   -- 1
    api.nvim_buf_add_highlight(bufnr, -1, 'Grey', row, 2, 3)  -- ]
    row = row + 1
  end

  local win_opts = vim.lsp.util.make_floating_popup_options(longest_line, row)
  win_opts.row, win_opts.col = unpack(offset[win_opts.anchor])
  win_opts.border = 'single'

  api.nvim_buf_set_option(bufnr, 'modifiable', false)
  api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')

  local winnr = api.nvim_open_win(bufnr, true, win_opts)
  set_mappings(bufnr, winnr, row - 2)
end

return M
