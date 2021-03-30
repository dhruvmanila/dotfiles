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
        preview_width = 0.5,
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
        ["<Esc>"] = actions.close,
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
map('n', '<Leader>;', [[<Cmd>lua require('plugin.telescope').buffers()<CR>]])

-- Grep
map('n', '<Leader>fl', [[<Cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]])
map('n', '<Leader>gr', [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]])

-- Git
map('n', '<Leader>gc', [[<Cmd>lua require('telescope.builtin').git_commits()<CR>]])

-- Find neovim stuff
map('n', '<Leader>fh', [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]])
map('n', '<Leader>fm', [[<Cmd>lua require('telescope.builtin').keymaps()<CR>]])
-- TODO: commands should show the underlying code which will be executed like fzf
map('n', '<Leader>fc', [[<Cmd>lua require('telescope.builtin').commands()<CR>]])
map('n', '<Leader>hi', [[<Cmd>lua require('telescope.builtin').highlights()<CR>]])

-- Enhanced with Telescope (NOTE: Use <nowait> for 'q' only keymap)
map('n', 'q:', [[<Cmd>lua require('telescope.builtin').command_history()<CR>]])
-- TODO: same thing for 'q/' (not present in telescope)

-- Custom config maps
map('n', '<Leader>fd', [[<Cmd>lua require('plugin.telescope').search_dotfiles()<CR>]])
map('n', '<Leader>fn', [[<Cmd>lua require('plugin.telescope').installed_plugins()<CR>]])
map('n', '<Leader>fa', [[<Cmd>lua require('plugin.telescope').search_all_files()<CR>]])
-- TODO: mix this with find_files?
map('n', '<Leader>fp', [[<Cmd>lua require('plugin.telescope').project_search()<CR>]])


require('telescope').load_extension('fzy_native')

-- Custom configuration
local M = {}

-- Project search using the '.git' pattern, defaults to the current directory.
--
-- This uses the root_pattern function from lspconfig.util module which returns
-- a function to which we can pass a directory and it will traverse the path
-- ancestors till it finds the root pattern we passed in.
function M.project_search()
  require('telescope.builtin').find_files {
    prompt_title = "Project Search",
    shorten_path = false,
    cwd = require('lspconfig.util').root_pattern('.git')(vim.fn.expand('%'))
  }
end

function M.search_dotfiles()
  require('telescope.builtin').find_files {
    prompt_title = "Search Dotfiles",
    shorten_path = false,
    cwd = "~/dotfiles",
    hidden = true,
    follow = true,
    file_ignore_patterns = {".git/.*"},
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

-- https://github.com/nvim-telescope/telescope.nvim/issues/621#issuecomment-802222898
-- Added the ability to delete multiple buffers in one go using multi-selection.
function M.buffers(opts)
  local action_state = require('telescope.actions.state')
  opts = opts or {}
  opts.previewer = false
  opts.sort_lastused = true
  opts.show_all_buffers = true
  opts.shorten_path = false
  opts.results_height = 20
  opts.attach_mappings = function(prompt_bufnr, map)
    local delete_buf = function()
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      local multi_selection = current_picker:get_multi_selection()

      if next(multi_selection) == nil then
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_buf_delete(selection.bufnr, {force = true})
      else
        actions.close(prompt_bufnr)
        for _, selection in ipairs(multi_selection) do
          vim.api.nvim_buf_delete(selection.bufnr, {force = true})
        end
      end
    end
    map('i', '<C-x>', delete_buf)
    return true
  end
  require('telescope.builtin').buffers(require('telescope.themes').get_dropdown(opts))
end

return M
