vim.opt_local.wrap = true

-- Avoid highlighting markdown blocks for hover windows. Neovim adds this variable to the floating
-- window it creates for hover.
if vim.w[vim.lsp.protocol.Methods.textDocument_hover] ~= nil then
  return
end

--- Highlight fenced and indented code blocks in markdown using extmarks.
---
--- Uses treesitter to find code blocks and applies the 'ColorColumn' highlight group as a
--- background highlight spanning the full width of each block.
local function highlight_code_blocks()
  local ns = vim.api.nvim_create_namespace 'md_code_hl'
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  local tree = vim.treesitter.get_parser(0, 'markdown'):parse()[1]
  local query = vim.treesitter.query.parse(
    'markdown',
    [[
((fenced_code_block) @_)
((indented_code_block) @indented)
    ]]
  )
  local root = tree:root()
  local start_row, _, end_row, _ = root:range()
  for id, node in query:iter_captures(root, 0, start_row, end_row) do
    if not node:has_error() then
      local name = query.captures[id]
      if name == 'indented' then
        start_row, _, _, _ = node:range()
        _, _, end_row, _ = node:child(node:child_count() - 1):range()
        end_row = end_row + 1
      else
        start_row, _, end_row, _ = node:range()
      end
      vim.api.nvim_buf_set_extmark(0, ns, start_row, 0, {
        end_row = end_row,
        hl_eol = true,
        hl_group = 'ColorColumn',
      })
    end
  end
end

vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  buffer = 0,
  callback = highlight_code_blocks,
})

highlight_code_blocks()
