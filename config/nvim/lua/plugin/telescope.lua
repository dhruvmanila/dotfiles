-- Ref: https://github.com/nvim-telescope/telescope.nvim
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local themes = require('telescope.themes')
local utils = require('core.utils')
local map = utils.map

local should_reload = true

if should_reload then
  RELOAD('plenary')
  RELOAD('popup')
  RELOAD('telescope')
end

-- Namespace to hold custom actions
local custom_actions = {}

-- Yank the selected entry into the selection register '*'
custom_actions.yank_entry = function(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  vim.fn.setreg(vim.api.nvim_get_vvar('register'), entry.value)

  vim.schedule(function()
    print("[telescope] Yanked: " .. entry.value)
  end)
end

-- Delete the selected buffer or all the buffers selected using multi selection.
custom_actions.delete_buffer = function (prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selection = current_picker:get_multi_selection()
  actions.close(prompt_bufnr)

  if vim.tbl_isempty(multi_selection) then
    local selection = action_state.get_selected_entry()
    vim.api.nvim_buf_delete(selection.bufnr, {force = true})
  else
    for _, selection in ipairs(multi_selection) do
      vim.api.nvim_buf_delete(selection.bufnr, {force = true})
    end
  end
end

require('telescope').setup {
  defaults = {
    prompt_prefix = require('core.icons').icons.telescope .. ' ',
    selection_caret = '❯ ',
    prompt_position = 'top',
    sorting_strategy = 'ascending',
    layout_strategy = 'horizontal',
    color_devicons = true,
    winblend = 15,
    file_ignore_patterns = {'__pycache__', '.mypy_cache'},
    layout_defaults = {
      horizontal = {
        preview_width = 0.55,
        width_padding = 0.05,
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
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-x>"] = false,
        ["<C-y>"] = custom_actions.yank_entry,
      },
    },
  },
  extensions = {
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    -- arecibo = {
    --   selected_engine = 'duckduckgo',
    --   url_open_command = 'open',
    --   show_http_headers = false,
    --   show_domain_icons = false,
    -- },
    bookmarks = {
      selected_browser = 'brave',
      url_open_command = 'open',
      -- url_open_plugin = 'vim_external',
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
  -- 'arecibo',
  'bookmarks',
  'github_stars',
  'installed_plugins',
  'startify_sessions',
})

-- Helper function to set the keymaps for telescope functions
local function tele_map(key, funcname, module)
  module = module or 'plugin.telescope'
  map('n', key, '<Cmd>lua require("' .. module .. '").' .. funcname .. '()<CR>')
end

-- Meta
tele_map('<Leader>te', 'builtin', 'telescope.builtin')

-- Files
tele_map('<C-p>',      'find_files')
tele_map('<Leader>;',  'buffers')
tele_map('<C-f>',      'current_buffer')
tele_map('<Leader>rp', 'grep_prompt')
tele_map('<Leader>rg', 'live_grep')
tele_map('<Leader>fd', 'search_dotfiles')
tele_map('<Leader>fp', 'installed_plugins')
tele_map('<Leader>fa', 'search_all_files')

-- Git
tele_map('<Leader>gc', 'git_commits', 'telescope.builtin')
tele_map('<Leader>gs', 'github_stars')

-- Neovim (NOTE: Use <nowait> for 'q' only keymap)
tele_map('<Leader>fh', 'help_tags')
tele_map('<Leader>fm', 'keymaps')
tele_map('<Leader>fc', 'commands')
tele_map('<Leader>hi', 'highlights')
tele_map('<Leader>fo', 'vim_options')
tele_map('q:',         'command_history')
tele_map('q/',         'search_history')

-- Extensions
tele_map('<Leader>fb', 'bookmarks')
-- tele_map('<Leader>fw', 'arecibo')
tele_map('<Leader>fs', 'startify_sessions')

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

function M.installed_plugins()
  require('telescope').extensions.installed_plugins.installed_plugins(
    themes.get_dropdown {
      width = _CachedPluginInfo.max_length + 10,
      results_height = 0.8,
      previewer = false,
    }
  )
end

function M.startify_sessions()
  require('telescope').extensions.startify_sessions.startify_sessions(
    themes.get_dropdown {
      width = 40,
      results_height = 0.5,
      previewer = false,
    }
  )
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
  require('telescope.builtin').command_history(
    themes.get_dropdown {
      width = math.min(100, vim.o.columns - 20),
      results_height = 0.8,
      previewer = false,
    }
  )
end

function M.search_history()
  require('telescope.builtin').search_history(
    themes.get_dropdown {
      width = math.min(100, vim.o.columns - 20),
      results_height = 0.8,
      previewer = false,
    }
  )
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

-- https://github.com/nvim-telescope/telescope.nvim/issues/621#issuecomment-802222898
-- Added the ability to delete multiple buffers in one go using multi-selection.
function M.buffers()
  require('telescope.builtin').buffers(themes.get_dropdown {
    previewer = false,
    sort_lastused = true,
    show_all_buffers = true,
    shorten_path = false,
    width = math.min(vim.o.columns - 20, 110),

    -- Height ranges from 10 to #lines - 10 (depending on the number of buffers)
    results_height = math.max(
      10, math.min(vim.o.lines - 10, #vim.fn.getbufinfo({buflisted = 1}))
    ),

    attach_mappings = function(_, tmap)
      tmap('i', '<C-x>', custom_actions.delete_buffer)
      tmap('n', '<C-x>', custom_actions.delete_buffer)
      return true
    end,
  })
end

return M
