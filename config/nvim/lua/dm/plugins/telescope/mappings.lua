local builtin = require 'telescope.builtin'
local telescope = require 'telescope'
local themes = require 'telescope.themes'

local pickers = require 'dm.plugins.telescope.pickers'

-- Smart tags picker which uses either the LSP symbols, treesitter symbols or
-- buffer tags, whichever is available first.
local function document_symbols()
  if #vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() } > 0 then
    builtin.lsp_document_symbols()
  elseif require('nvim-treesitter.parsers').has_parser() then
    builtin.treesitter()
  else
    builtin.current_buffer_tags()
  end
end

-- Grep the regex pattern over the current working directory.
local function grep_pattern()
  local pattern = vim.fn.input 'Grep pattern ❯ '
  if pattern ~= '' then
    builtin.grep_string {
      prompt_title = ('Find Pattern » %s «'):format(pattern),
      use_regex = true,
      search = pattern,
    }
  end
end

-- Grep for the `<cword>` over the current working directory.
local function grep_cword()
  local word = vim.fn.expand '<cword>'
  builtin.grep_string {
    prompt_title = ('Find word » %s «'):format(word),
    search = word,
  }
end

-- Grep for the `<cWORD>` over the current working directory.
local function grep_cword2()
  local word = vim.fn.expand '<cWORD>'
  builtin.grep_string {
    prompt_title = ('Find WORD » %s «'):format(word),
    search = word,
  }
end

---@type { [1]: string, [2]: string, [3]: function, desc: string }[]
local mappings = {
  -- We cannot bind every builtin picker to a keymap and so this will help us
  -- when we are in need of a rarely used picker.
  { 'n', ';t', builtin.builtin, desc = 'builtin pickers' },
  { 'n', '<leader>fr', builtin.resume, desc = 'resume last picker' },

  -- Files
  { 'n', '<C-p>', pickers.find_files, desc = 'find files' },
  { 'n', '<leader>;', builtin.buffers, desc = 'buffers' },
  { 'n', '<leader>fl', builtin.current_buffer_fuzzy_find, desc = 'current buffer find' },

  -- IntelliSense
  { 'n', '<leader>fd', builtin.diagnostics, desc = 'diagnostics' },
  { 'n', '<leader>fs', document_symbols, desc = 'document symbols' },
  { 'n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, desc = 'dynamic workspace symbols' },

  -- Git
  { 'n', ';b', builtin.git_branches, desc = 'git branches' },
  { 'n', '<leader>gc', builtin.git_commits, desc = 'git commits' },
  { 'n', '<leader>bc', builtin.git_bcommits, desc = 'git commits (buffer)' },
  { 'x', '<leader>bc', builtin.git_bcommits_range, desc = 'git commits (selection)' },

  -- Neovim
  { 'n', '<leader>fh', builtin.help_tags, desc = 'help tags' },

  -- Custom pickers
  { 'n', '<leader>rp', grep_pattern, desc = 'grep pattern' },
  { 'n', '<leader>rw', grep_cword, desc = 'grep cword' },
  { 'n', '<leader>rW', grep_cword2, desc = 'grep cWORD' },
}

for _, m in ipairs(mappings) do
  vim.keymap.set(m[1], m[2], m[3], { desc = ('telescope: %s'):format(m.desc) })
end

-- Extensions

vim.keymap.set('n', '<leader>gs', function()
  telescope.extensions.custom.github_stars()
end, { desc = 'telescope: GitHub stars' })

vim.keymap.set('n', '<leader>fp', function()
  telescope.extensions.custom.installed_plugins(themes.get_dropdown {
    layout_config = {
      width = 50,
      height = 0.5,
    },
    previewer = false,
  })
end, { desc = 'telescope: installed plugins' })
