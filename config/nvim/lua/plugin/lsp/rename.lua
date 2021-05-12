local api = vim.api
local lsp = vim.lsp
local cmd = api.nvim_command
local utils = require("core.utils")
local icons = require("core.icons")

local M = {}

local state = {}

local prompt_title = "New name:"

local offset = {
  NW = { 1, 2 },
  NE = { 1, -2 },
  SW = { -1, 2 },
  SE = { -1, -2 },
}

local function create_border(opts)
  local border = opts.border or icons.border.default
  local title = opts.title and " " .. opts.title .. " " or ""
  local content_width = opts.width - 2

  local top = string.format(
    "%s%s%s%s",
    border[1],
    title,
    string.rep(border[2], content_width - #title),
    border[3]
  )

  local mid = string.format(
    "%s%s%s",
    border[8],
    string.rep(" ", content_width),
    border[4]
  )

  local bot = string.format(
    "%s%s%s",
    border[7],
    string.rep(border[6], content_width),
    border[5]
  )

  local lines = {}
  table.insert(lines, top)
  for _ = 1, opts.height do
    table.insert(lines, mid)
  end
  table.insert(lines, bot)

  return lines
end

local function bordered_window(opts)
  local lines = create_border(opts)
  local border_bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(border_bufnr, "bufhidden", "wipe")
  api.nvim_buf_set_lines(border_bufnr, 0, -1, false, lines)

  local win_opts = utils.make_floating_popup_options(opts.width, #lines)
  win_opts.focusable = false
  local border_winnr = api.nvim_open_win(border_bufnr, false, win_opts)
  api.nvim_win_set_option(border_winnr, "winhl", "NormalFloat:Normal")

  local row_offset, col_offset = unpack(offset[win_opts.anchor])
  win_opts.width = win_opts.width - 4
  win_opts.height = win_opts.height - 2
  win_opts.row = win_opts.row + row_offset
  win_opts.col = win_opts.col + col_offset
  win_opts.focusable = true

  local bufnr = api.nvim_create_buf(false, true)
  local winnr = api.nvim_open_win(bufnr, true, win_opts)
  return winnr, bufnr, { winnr = border_winnr }
end

local function set_mappings(bufnr)
  local bufmap = api.nvim_buf_set_keymap
  local opts = { noremap = true, silent = true, nowait = true }
  local callback_fn = "<Cmd>lua require('plugin.lsp.rename').callback()<CR>"
  local cleanup_fn = "<Cmd>lua require('plugin.lsp.rename').cleanup()<CR>"
  local clear_fn = string.format(
    "<Cmd>lua vim.api.nvim_buf_set_lines(%d, 0, -1, false, {})<CR>",
    bufnr
  )

  bufmap(bufnr, "i", "<CR>", "<C-o>" .. callback_fn, opts)
  bufmap(bufnr, "n", "<CR>", callback_fn, opts)
  bufmap(bufnr, "i", "<esc>", "<C-o>" .. cleanup_fn, opts)
  bufmap(bufnr, "n", "<esc>", cleanup_fn, opts)
  bufmap(bufnr, "i", "<C-l>", clear_fn, opts)
end

function M.callback()
  local orig_name, orig_bufnr = state.orig_name, state.orig_bufnr
  local new_name = api.nvim_buf_get_lines(state.prompt_bufnr, 0, -1, false)[1]
  M.cleanup()
  if #new_name == 0 or new_name == orig_name then
    return
  end
  local params = lsp.util.make_position_params()
  params.newName = new_name
  lsp.buf_request(orig_bufnr, "textDocument/rename", params)
end

function M.cleanup()
  cmd("stopinsert")
  for _, winnr in ipairs(state.windows) do
    if api.nvim_win_is_valid(winnr) then
      api.nvim_win_close(winnr, true)
    end
  end
  state = {}
end

function M.rename()
  state.orig_name = vim.fn.expand("<cword>")
  state.orig_bufnr = api.nvim_get_current_buf()
  local prompt_winnr, prompt_bufnr, border = bordered_window({
    title = prompt_title,
    width = 40,
    height = 1,
  })

  api.nvim_buf_set_option(prompt_bufnr, "buftype", "nofile")
  api.nvim_buf_set_option(prompt_bufnr, "bufhidden", "wipe")
  api.nvim_win_set_option(prompt_winnr, "wrap", false)
  api.nvim_win_set_option(prompt_winnr, "winhl", "NormalFloat:Normal")

  state.windows = { prompt_winnr, border.winnr }
  state.prompt_bufnr = prompt_bufnr

  cmd(string.format(
    "autocmd BufWipeout <buffer=%d> lua require('plugin.lsp.rename').cleanup()",
    prompt_bufnr
  ))
  set_mappings(prompt_bufnr)
  api.nvim_buf_set_lines(prompt_bufnr, 0, 1, false, { state.orig_name })
  cmd("startinsert!")
end

return M
