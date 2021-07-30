local api = vim.api
local lsp = vim.lsp

local M = {}

-- Create a namespace for the lightbulb extmark.
local LIGHTBULB_EXTMARK_NS = api.nvim_create_namespace "dm__lsp_lightbulb"

-- Code action listener to set and update the lightbulb to indicate that there
-- are code actions available on that line.
function M.code_action_listener()
  local params = lsp.util.make_range_params()
  params.context = { diagnostics = lsp.diagnostic.get_line_diagnostics() }
  lsp.buf_request(
    0,
    "textDocument/codeAction",
    params,
    function(err, _, response)
      -- Don't do anything if the request returned an error.
      if err then
        return
      end
      -- Remove all the existing lightbulbs.
      api.nvim_buf_clear_namespace(0, LIGHTBULB_EXTMARK_NS, 0, -1)
      if response and not vim.tbl_isempty(response) then
        local line = params.range.start.line
        api.nvim_buf_set_extmark(0, LIGHTBULB_EXTMARK_NS, line, 0, {
          virt_text = { { "", "YellowSign" } },
          virt_text_pos = "overlay",
          hl_mode = "combine",
        })
      end
    end
  )
end

return M
