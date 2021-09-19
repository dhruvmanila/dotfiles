local api = vim.api
local opt_local = vim.opt_local

-- To make it compatible with jupytext percent format
vim.b.slime_cell_delimiter = "# %%"

opt_local.makeprg = "python3 %"
opt_local.formatprg = "black --quiet - | isort --quiet --profile=black -"

dm.command("PyDoc", function(word, mods)
  mods = mods or ""

  -- Extract the 'word' at the cursor {{{
  --
  -- By expanding leftwards across identifiers and the '.' operator, and
  -- rightwards across the identifier only.
  --
  -- For example:
  --   `import xml.dom.minidom`
  --            ^   !
  --
  -- With the cursor at ^ this returns 'xml'; at ! it returns 'xml.dom'.
  -- }}}
  if not word or word == "" then
    local _, col = unpack(api.nvim_win_get_cursor(0))
    local line = api.nvim_get_current_line()
    word = line:sub(0, col):match "[%w_.]*$" .. line:match("^[%w_]*", col + 1)
  end

  local lines = {}
  local fd = io.popen("python -m pydoc " .. word)
  for line in fd:lines() do
    lines[#lines + 1] = line
  end
  fd:close()

  -- In case `pydoc` cannot find the documentation for `word` {{{
  --
  -- The output is:
  --
  --     > No Python documentation found for '<word>'.
  --     > Use help() to get the interactive help utility.
  --     > Use help(str) for help on the str class.
  --
  -- We are only interested in the first line.
  -- }}}
  if #lines < 5 then
    return dm.notify("PyDoc", lines[1])
  end

  vim.cmd(mods .. " split __doc__")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.readonly = true
  vim.bo.modifiable = false
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "man"
  vim.bo.bufhidden = "wipe"
end, {
  buffer = true,
  nargs = "?",
})

-- Similar to how `gf` works with a different keymap of `gK` for vertical split.
dm.nnoremap("gk", "<Cmd>PyDoc<CR>", { buffer = true })
dm.nnoremap("gK", "<Cmd>vertical PyDoc<CR>", { buffer = true })
dm.nnoremap("<C-w>gk", "<Cmd>tab PyDoc<CR>", { buffer = true })
