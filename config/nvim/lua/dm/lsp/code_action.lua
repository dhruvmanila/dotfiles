local M = {}

local log = require 'dm.log'

-- Create a namespace for the lightbulb extmark.
local LIGHTBULB_EXTMARK_NS = vim.api.nvim_create_namespace 'dm__lsp_lightbulb'

local RUST_ANALYZER_WAIT_MESSAGE = 'waiting for cargo metadata or cargo check'

-- Code action listener to set and update the lightbulb to indicate that there
-- are code actions available on that line.
function M.listener()
  local params = vim.lsp.util.make_range_params()
  params.context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  vim.lsp.buf_request(
    0,
    'textDocument/codeAction',
    params,
    function(err, result, ctx)
      if err then
        if err.message == RUST_ANALYZER_WAIT_MESSAGE then
          return log.fmt_debug('LSP (%s): %s', ctx.method, err)
        end
        return log.fmt_error('LSP (%s): %s', ctx.method, err)
      end
      -- Remove all the existing lightbulbs.
      vim.api.nvim_buf_clear_namespace(0, LIGHTBULB_EXTMARK_NS, 0, -1)
      if result and not vim.tbl_isempty(result) then
        local line = params.range.start.line
        vim.api.nvim_buf_set_extmark(0, LIGHTBULB_EXTMARK_NS, line, 0, {
          virt_text = { { '', 'Yellow' } },
          virt_text_pos = 'overlay',
          hl_mode = 'combine',
        })
      end
    end
  )
end

return M
