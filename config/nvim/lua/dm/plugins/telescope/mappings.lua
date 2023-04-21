local telescope = require 'telescope'
local builtin = require 'telescope.builtin'
local ts_parsers = require 'nvim-treesitter.parsers'

local themes = require 'dm.plugins.telescope.themes'
local pickers = require 'dm.plugins.telescope.pickers'

-- Builtin Pickers

-- We cannot bind every builtin picker to a keymap and so this will help us
-- when we are in need of a rarely used picker.
vim.keymap.set('n', ';t', builtin.builtin, {
  desc = 'Telescope: Builtin pickers',
})
vim.keymap.set('n', '<leader>fr', builtin.resume, {
  desc = 'Telescope: Resume last picker',
})

vim.keymap.set('n', '<C-p>', pickers.find_files, {
  desc = 'Telescope: Find files',
})
vim.keymap.set('n', '<leader>;', builtin.buffers, {
  desc = 'Telescope: Buffers',
})
vim.keymap.set('n', '<leader>fl', builtin.current_buffer_fuzzy_find, {
  desc = 'Telescope: Current buffer fuzzy find',
})

vim.keymap.set('n', '<leader>rg', builtin.live_grep, {
  desc = 'Telescope: Live grep',
})

-- Smart tags picker which uses either the LSP symbols, treesitter symbols or
-- buffer tags, whichever is available first.
vim.keymap.set('n', '<leader>ft', function()
  if
    #vim.lsp.get_active_clients { bufnr = vim.api.nvim_get_current_buf() } > 0
  then
    builtin.lsp_document_symbols()
  elseif ts_parsers.has_parser() then
    builtin.treesitter()
  else
    builtin.current_buffer_tags()
  end
end, { desc = 'Telescope: LSP symbols / treesitter symbols / buffer tags' })

-- Git
vim.keymap.set('n', ';b', builtin.git_branches, {
  desc = 'Telescope: Git branches',
})
vim.keymap.set('n', '<leader>gc', builtin.git_commits, {
  desc = 'Telescope: Git commits',
})
vim.keymap.set('n', '<leader>bc', builtin.git_bcommits, {
  desc = 'Telescope: Git commits (buffer)',
})

-- Neovim
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {
  desc = 'Telescope: Help tags',
})
vim.keymap.set('n', '<leader>fc', builtin.commands, {
  desc = 'Telescope: Commands',
})
vim.keymap.set('n', '<leader>:', builtin.command_history, {
  desc = 'Telescope: Command history',
})
vim.keymap.set('n', '<leader>/', builtin.search_history, {
  desc = 'Telescope: Search history',
})

-- Custom pickers

vim.keymap.set('n', '<leader>fd', function()
  builtin.git_files {
    prompt_title = 'Find dotfiles',
    cwd = '~/dotfiles',
  }
end, { desc = 'Telescope: Find dotfiles' })

-- This is mainly to avoid .gitignore patterns.
vim.keymap.set('n', '<leader>fa', function()
  builtin.find_files {
    prompt_title = 'Find All Files',
    hidden = true,
    follow = true,
    no_ignore = true,
    file_ignore_patterns = { '.git/' },
  }
end, { desc = 'Telescope: Find all files' })

vim.keymap.set('n', '<leader>rp', function()
  local pattern = vim.fn.input 'Grep pattern ❯ '
  if pattern ~= '' then
    builtin.grep_string {
      prompt_title = ('Find Pattern » %s «'):format(pattern),
      use_regex = true,
      search = pattern,
    }
  end
end, { desc = 'Telescope: Grep given pattern' })

vim.keymap.set('n', '<leader>rw', function()
  local word = vim.fn.expand '<cword>'
  builtin.grep_string {
    prompt_title = ('Find word » %s «'):format(word),
    search = word,
  }
end, { desc = 'Telescope: Grep current word' })

vim.keymap.set('n', '<leader>rW', function()
  local word = vim.fn.expand '<cWORD>'
  builtin.grep_string {
    prompt_title = ('Find WORD » %s «'):format(word),
    search = word,
  }
end, { desc = 'Telescope: Grep current WORD' })

-- Extensions

vim.keymap.set('n', '<leader>gs', function()
  telescope.extensions.custom.github_stars()
end, { desc = 'Telescope: GitHub stars' })

vim.keymap.set('n', '<leader>fw', function()
  telescope.extensions.custom.websearch()
end, { desc = 'Telescope: Websearch' })

vim.keymap.set('n', '<leader>fi', function()
  telescope.extensions.custom.icons()
end, { desc = 'Telescope: Icons' })

vim.keymap.set('n', '<leader>fp', function()
  telescope.extensions.custom.installed_plugins(themes.dropdown_list)
end, { desc = 'Telescope: Installed plugins' })

vim.keymap.set('n', '<leader>fb', function()
  telescope.extensions.bookmarks.bookmarks()
end, { desc = 'Telescope: Browser bookmarks' })

vim.keymap.set('n', '<leader>fs', function()
  telescope.extensions.custom.sessions(themes.dropdown_list)
end, { desc = 'Telescope: Sessions' })
