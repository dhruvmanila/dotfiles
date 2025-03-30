local M = {}

-- Create a namespace for the lightbulb extmark.
local LIGHTBULB_EXTMARK_NS = vim.api.nvim_create_namespace 'dm__lsp_lightbulb'

local RUST_ANALYZER_WAIT_MESSAGE = 'waiting for cargo metadata or cargo check'

-- Code action listener to set and update the lightbulb to indicate that there
-- are quickfix code actions available on that line.
function M.listener()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_range_params()
  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- row is 1-indexed
  params.context = {
    diagnostics = vim.lsp.diagnostic.from(vim.diagnostic.get(bufnr, { lnum = current_line })),
    only = {
      vim.lsp.protocol.CodeActionKind.QuickFix,
      vim.lsp.protocol.CodeActionKind.Refactor,
    },
  }
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx)
    if err then
      if err.message == RUST_ANALYZER_WAIT_MESSAGE then
        return dm.log.debug('LSP (%s): %s', ctx.method, err)
      end
      return dm.log.error('LSP (%s): %s', ctx.method, err)
    end
    -- Remove all the existing lightbulbs.
    vim.api.nvim_buf_clear_namespace(bufnr, LIGHTBULB_EXTMARK_NS, 0, -1)
    -- We've switched buffer by the time the server responded.
    if vim.api.nvim_get_current_buf() ~= bufnr then
      return
    end
    if result and not vim.tbl_isempty(result) then
      local line = params.range.start.line
      vim.api.nvim_buf_set_extmark(0, LIGHTBULB_EXTMARK_NS, line, 0, {
        virt_text = { { '', 'Yellow' } },
        virt_text_pos = 'overlay',
        hl_mode = 'combine',
      })
    end
  end)
end

return M
