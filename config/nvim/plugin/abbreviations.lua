-- Helper function to create an abbreviation for normal Ex command at the
-- start position.
--
-- For example, if short is 'nm' and long is 'Neovim', then:
--    :nm -> :Neovim
--    /nm -> /nm  (not an Ex command)
--    :foo nm -> :foo nm (not at the start position)
---@param short string
---@param long string
local function cabbrev(short, long)
  local cmdpos = #short + 1
  vim.api.nvim_set_keymap('ca', short, '', {
    expr = true,
    callback = function()
      if vim.fn.getcmdtype() == ':' and vim.fn.getcmdpos() == cmdpos then
        return long
      else
        return short
      end
    end,
  })
end

-- Session commands
cabbrev('sc', 'SClose')
cabbrev('sd', 'SDelete')
cabbrev('sl', 'SLoad')
cabbrev('sr', 'SRename')
cabbrev('ss', 'SSave')

-- :so -> :source %
cabbrev('so', 'source %')

-- For better readability (`tpope/vim-scriptease`)
cabbrev('mes', 'Message')
cabbrev('veb', 'Verbose')
