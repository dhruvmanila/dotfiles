-- Ref: https://github.com/nvim-telescope/telescope.nvim
local actions = require('telescope.actions')
local map = require('core.utils').map

require('telescope').setup {
  defaults = {
    prompt_prefix = require('nvim-nonicons').get('telescope') .. ' ',
    prompt_position = 'top',
    selection_caret = '❯ ',
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    color_devicons = true,
    layout_defaults = {
      horizontal = {
        preview_width = 0.6,
        width_padding = 0.1,
        height_padding = 0.1,
      },
      vertical = {
        preview_height = 0.5,
        width_padding = 0.05,
        height_padding = 0.05,
      }
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous
      },
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      }
    },
  }
}

-- Meta
map('n', '<Leader>te', [[<Cmd>lua require('telescope.builtin').builtin()<CR>]])

-- Quick file navigation
map('n', '<C-p>', [[<Cmd>lua require('telescope.builtin').find_files()<CR>]])
map('n', '<Leader>;', [[<Cmd>lua require('telescope.builtin').buffers()<CR>]])

-- Grep
map('n', '<Leader>fl', [[<Cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]])
map('n', '<Leader>gr', [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]])

-- Git
map('n', '<Leader>gc', [[<Cmd>lua require('telescope.builtin').git_commits()<CR>]])

-- Find neovim stuff
map('n', '<Leader>fh', [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]])
map('n', '<Leader>fm', [[<Cmd>lua require('telescope.builtin').keymaps()<CR>]])
map('n', '<Leader>fc', [[<Cmd>lua require('telescope.builtin').commands()<CR>]])
map('n', '<Leader>hi', [[<Cmd>lua require('telescope.builtin').highlights()<CR>]])

-- Enhanced with Telescope (NOTE: Use <nowait> for 'q' only keymap)
map('n', 'q:', [[<Cmd>lua require('telescope.builtin').command_history()<CR>]])
-- TODO: same thing for 'q/' (not present in telescope)

-- Custom config maps
map('n', '<Leader>fd', [[<Cmd>lua require('plugin.telescope').search_dotfiles()<CR>]])
map('n', '<Leader>fn', [[<Cmd>lua require('plugin.telescope').installed_plugins()<CR>]])
map('n', '<Leader>fa', [[<Cmd>lua require('plugin.telescope').search_all_files()<CR>]])


require('telescope').load_extension('fzy_native')

-- Custom configuration
local M = {}

function M.search_dotfiles()
  require('telescope.builtin').find_files {
    prompt_title = "Search Dotfiles",
    shorten_path = false,
    cwd = "~/dotfiles",
    find_command = {
      'fd', '--hidden', '--follow', '--exclude', '.git', '--no-ignore'
    },
  }
end

function M.installed_plugins()
  require('telescope.builtin').find_files {
    prompt_title = "Installed Plugins",
    shorten_path = false,
    cwd = vim.fn.stdpath('data') .. '/site/pack/packer/'
  }
end

function M.search_all_files()
  require('telescope.builtin').find_files {
    prompt_title = "Search All Files",
    shorten_path = false,
    find_command = {
      'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git', '--no-ignore'
    },
  }
end

return M
