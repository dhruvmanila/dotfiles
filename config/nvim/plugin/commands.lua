local fn = vim.fn
local api = vim.api
local nvim_add_user_command = api.nvim_add_user_command

-- BufOnly {{{1

nvim_add_user_command("BufOnly", function()
  local deleted, modified = 0, 0
  local curr_buf = api.nvim_get_current_buf()
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted then
      if vim.bo[bufnr].modified then
        modified = modified + 1
      elseif bufnr ~= curr_buf and vim.bo[bufnr].buftype ~= "terminal" then
        api.nvim_buf_delete(bufnr, {})
        deleted = deleted + 1
      end
    end
  end
  if deleted > 0 then
    local info = { deleted .. " deleted buffer(s)" }
    if modified > 0 then
      table.insert(info, modified .. " modified buffer(s)")
    end
    dm.notify("BufOnly", info)
  end
end, {
  force = true,
  desc = "Delete all but the current buffer (ignores terminal buffers)",
})

-- Dap {{{1

local dap_functions = {
  "clear_breakpoints",
  "close",
  "continue",
  "disconnect",
  "reverse_continue",
  "run_last",
  "run_to_cursor",
  "set_breakpoint",
  "set_exception_breakpoints",
  "step_back",
  "step_into",
  "step_out",
  "step_over",
  "terminate",
  "toggle_breakpoint",
}

nvim_add_user_command("Dap", function(opts)
  require("dap")[opts.args]()
end, {
  nargs = 1,
  complete = function(arglead)
    arglead = arglead and (".*" .. arglead .. ".*")
    return vim.tbl_filter(function(fname)
      return fname:match(arglead)
    end, dap_functions)
  end,
  desc = "Custom command for all nvim-dap functions",
})

-- LspClient {{{1

nvim_add_user_command("LspClient", function(opts)
  local info
  if opts.args ~= "" then
    info = vim.lsp.get_client_by_id(opts.args)
  else
    info = vim.lsp.buf_get_clients()
  end
  print(vim.inspect(info))
end, {
  force = true,
  nargs = "?",
  complete = function()
    -- https://github.com/neovim/nvim-lspconfig/blob/master/plugin/lspconfig.vim#L10
    return lsp_get_active_client_ids()
  end,
  desc = "Print information for given client id, or all clients if none given",
})

-- LspLog {{{1

-- Do NOT define the command as plain string because the module `vim.lsp` is
-- expensive to load on startup.

nvim_add_user_command("LspLog", function()
  vim.cmd("botright split | resize 20 | edit + " .. vim.lsp.get_log_path())
end, {
  force = true,
  desc = "Open logs for the builtin LSP client",
})

-- Term / Vterm / Tterm {{{1

nvim_add_user_command("Term", "new | wincmd J | resize -5 | term", {
  force = true,
  desc = "Open the terminal on the bottom occupying full width of the editor",
})

nvim_add_user_command("Vterm", "vnew | wincmd L | term", {
  force = true,
  desc = "Open the terminal on the right hand side occupying full height of the editor",
})

nvim_add_user_command("Tterm", "tabnew | term", {
  force = true,
  desc = "Open the terminal in a new tab",
})

-- Todo {{{1

nvim_add_user_command(
  "Todo",
  [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]],
  {
    force = true,
    desc = "List out all the location where todos and other related keywords are present in the current project",
  }
)

-- TrimLines {{{1

nvim_add_user_command("TrimLines", function()
  local pos = api.nvim_win_get_cursor(0)
  local last_line = api.nvim_buf_line_count(0)
  local last_non_blank_line = fn.prevnonblank(last_line)

  if last_non_blank_line > 0 and last_line ~= last_non_blank_line then
    api.nvim_buf_set_lines(0, last_non_blank_line, last_line, false, {})
  end

  api.nvim_win_set_cursor(0, pos)
end, {
  bar = true,
  force = true,
  desc = "Trim blank lines at the end of the current buffer, restoring the cursor position",
})

-- TrimWhitespace {{{1

-- Purpose: Trim trailing whitespace for the current buffer, restoring the
-- cursor position. This command can be followed by another command.
nvim_add_user_command("TrimWhitespace", function()
  local pos = api.nvim_win_get_cursor(0)
  vim.cmd [[keeppatterns keepjumps %s/\s\+$//e]]
  api.nvim_win_set_cursor(0, pos)
end, {
  bar = true,
  force = true,
  desc = "Trim trailing whitespace for the current buffer, restoring the cursor position",
})
