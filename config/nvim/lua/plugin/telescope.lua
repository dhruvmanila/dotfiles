-- Ref: https://github.com/nvim-telescope/telescope.nvim
local actions = require('telescope.actions')
local themes = require('telescope.themes')
local utils = require('core.utils')
local map = utils.map

local should_reload = true

if should_reload then
  RELOAD('plenary')
  RELOAD('popup')
  RELOAD('telescope')
end

require('telescope').setup {
  defaults = {
    prompt_prefix = require('core.icons').icons.telescope .. ' ',
    selection_caret = '❯ ',
    prompt_position = 'top',
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    color_devicons = true,
    file_ignore_patterns = {'__pycache__', '.mypy_cache'},
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
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.send_to_qflist,
      },
    },
  },
  extensions = {
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    arecibo = {
      selected_engine = 'duckduckgo',
      url_open_command = 'open',
      show_http_headers = false,
      show_domain_icons = false,
    },
    bookmarks = {
      selected_browser = 'brave',
      url_open_command = 'open',
    },
  },
}

---TODO: Any way to lazy load telescope extensions? Same as from packer.nvim?
---Helper function to load the telescope extensions without blowing up.
---It only emits a small warning :)
---@param extensions table
local function load_telescope_extensions(extensions)
  for _, name in ipairs(extensions) do
    local ok, _ = pcall(require('telescope').load_extension, name)
    if not ok then
      vim.api.nvim_echo(
        {{'[Telescope] Failed to load the extension: ' .. name, 'WarningMsg'}}, true, {}
      )
    end
  end
end

-- Load the extensions
load_telescope_extensions({
  'fzf',
  'arecibo',
  'bookmarks',
  'github_stars',
  'installed_plugins',
})

-- Meta
map('n', '<Leader>te', [[<Cmd>lua require('telescope.builtin').builtin()<CR>]])

-- Files
map('n', '<C-p>', [[<Cmd>lua require('plugin.telescope').find_files()<CR>]])
map('n', '<Leader>;', [[<Cmd>lua require('plugin.telescope').buffers()<CR>]])
map('n', '<C-f>', [[<Cmd>lua require('plugin.telescope').current_buffer()<CR>]])
map('n', '<Leader>rp', [[<Cmd>lua require('plugin.telescope').grep_prompt()<CR>]])
map('n', '<Leader>rg', [[<Cmd>lua require('plugin.telescope').live_grep()<CR>]])
map('n', '<Leader>fd', [[<Cmd>lua require('plugin.telescope').search_dotfiles()<CR>]])
map('n', '<Leader>fp', [[<Cmd>lua require('plugin.telescope').installed_plugins()<CR>]])
map('n', '<Leader>fa', [[<Cmd>lua require('plugin.telescope').search_all_files()<CR>]])

-- Git
map('n', '<Leader>gc', [[<Cmd>lua require('telescope.builtin').git_commits()<CR>]])
map('n', '<Leader>gs', [[<Cmd>lua require('plugin.telescope').github_stars()<CR>]])

-- Neovim (NOTE: Use <nowait> for 'q' only keymap)
map('n', '<Leader>fh', [[<Cmd>lua require('plugin.telescope').help_tags()<CR>]])
map('n', '<Leader>fm', [[<Cmd>lua require('plugin.telescope').keymaps()<CR>]])
map('n', '<Leader>fc', [[<Cmd>lua require('plugin.telescope').commands()<CR>]])
map('n', '<Leader>hi', [[<Cmd>lua require('plugin.telescope').highlights()<CR>]])
map('n', '<Leader>fo', [[<Cmd>lua require('plugin.telescope').vim_options()<CR>]])
map('n', 'q:', [[<Cmd>lua require('plugin.telescope').command_history()<CR>]])

-- Extensions
map('n', '<Leader>fb', [[<Cmd>lua require('plugin.telescope').bookmarks()<CR>]])
map('n', '<Leader>fw', [[<Cmd>lua require('plugin.telescope').arecibo()<CR>]])

-- Entrypoints which will allow me to configure each command individually.
local M = {}

---Default no previewer dropdown theme opts.
local function no_previewer()
  return themes.get_dropdown {
    width = 0.8,
    results_height = 0.8,
    previewer = false,
  }
end

---Generic function to find files in given directory.
---Also used in installed_plugins extension
function M.find_files_in_dir(dir, opts)
  local dir_opts = {
    prompt_title = "Find Files (" .. vim.fn.fnamemodify(dir, ":t") .. ")",
    cwd = dir,
  }
  dir_opts = vim.tbl_deep_extend("force", dir_opts, opts)
  require('telescope.builtin').find_files(dir_opts)
end

function M.find_files()
  local cwd = utils.get_project_root()
  M.find_files_in_dir(cwd, {
    shorten_path = false,
    cwd = cwd,
  })
end

function M.grep_prompt()
  local cwd = utils.get_project_root()
  require('telescope.builtin').grep_string {
    cwd = cwd,
    shorten_path = true,
    search = vim.fn.input('Grep String > '),
  }
end

function M.live_grep()
  local cwd = utils.get_project_root()
  require('telescope.builtin').live_grep {
    cwd = cwd,
    shorten_path = true,
  }
end

function M.search_dotfiles()
  M.find_files_in_dir("~/dotfiles", {
    shorten_path = false,
    hidden = true,
    follow = true,
    file_ignore_patterns = {".git/"},
  })
end

-- function M.installed_plugins()
--   M.find_files_in_dir(vim.fn.stdpath('data') .. '/site/pack/packer/', {
--     prompt_title = "Installed Plugins",
--     shorten_path = false,
--     follow = true,
--   })
-- end

function M.search_all_files()
  require('telescope.builtin').find_files {
    prompt_title = "Search All Files",
    shorten_path = false,
    find_command = {
      'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git', '--no-ignore'
    },
  }
end

function M.help_tags()
  require('telescope.builtin').help_tags {
    layout_config = {
      preview_width = 0.65,
      width_padding = 0.10,
    }
  }
end

function M.highlights()
  require('telescope.builtin').highlights {
    layout_config = {
      preview_width = 0.65,
      width_padding = 0.10,
    }
  }
end

function M.current_buffer()
  require('telescope.builtin').current_buffer_fuzzy_find(no_previewer())
end

function M.vim_options()
  require('telescope.builtin').vim_options(no_previewer())
end

function M.keymaps()
  require('telescope.builtin').keymaps(no_previewer())
end

function M.commands()
  require('telescope.builtin').commands(no_previewer())
end

function M.command_history()
  require('telescope.builtin').command_history(no_previewer())
end

function M.arecibo()
  require('telescope').extensions.arecibo.websearch(no_previewer())
end

function M.bookmarks()
  require('telescope').extensions.bookmarks.bookmarks(no_previewer())
end

function M.github_stars()
  require('telescope').extensions.github_stars.github_stars(no_previewer())
end

-- TODO: change the name to installed_plugins and remove the old one
function M.installed_plugins()
  require('telescope').extensions.installed_plugins.installed_plugins(
    themes.get_dropdown {
      width = _CachedPluginInfo.max_length + 10,
      results_height = 0.8,
      previewer = false,
    }
  )
end

-- https://github.com/nvim-telescope/telescope.nvim/issues/621#issuecomment-802222898
-- Added the ability to delete multiple buffers in one go using multi-selection.
function M.buffers(opts)
  -- local action_state = require('telescope.actions.state')
  opts = opts or {}
  opts.previewer = false
  opts.sort_lastused = true
  opts.show_all_buffers = true
  opts.shorten_path = false
  opts.width = math.min(vim.o.columns - 20, 110)
  -- Height ranges from 10 to #lines - 10 (depending on the number of buffers)
  opts.results_height = math.max(
    10, math.min(vim.o.lines - 10, #vim.fn.getbufinfo({buflisted = 1}))
  )
  opts.attach_mappings = function(_, tele_map)
    tele_map('i', '<C-x>', actions.delete_buffer)
    tele_map('n', '<C-x>', actions.delete_buffer)
    return true
  end

  require('telescope.builtin').buffers(themes.get_dropdown(opts))
end

return M
