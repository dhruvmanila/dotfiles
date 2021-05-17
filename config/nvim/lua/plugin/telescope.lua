-- Ref: https://github.com/nvim-telescope/telescope.nvim
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")
local utils = require("core.utils")
local map = utils.map

local should_reload = true

if should_reload then
  RELOAD("plenary")
  RELOAD("popup")
  RELOAD("telescope")
end

-- Namespace to hold custom actions
local custom_actions = {}

-- Yank the selected entry into the selection register '*'
custom_actions.yank_entry = function(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  -- actions.close(prompt_bufnr)
  vim.fn.setreg(vim.api.nvim_get_vvar("register"), entry.value)

  vim.schedule(function()
    print("[telescope] Yanked: " .. entry.value)
  end)
end

-- Delete the selected buffer or all the buffers selected using multi selection.
-- custom_actions.delete_buffer = function(prompt_bufnr)
--   local current_picker = action_state.get_current_picker(prompt_bufnr)
--   local multi_selection = current_picker:get_multi_selection()
--   actions.close(prompt_bufnr)

--   if vim.tbl_isempty(multi_selection) then
--     local selection = action_state.get_selected_entry()
--     vim.api.nvim_buf_delete(selection.bufnr, {force = true})
--   else
--     for _, selection in ipairs(multi_selection) do
--       vim.api.nvim_buf_delete(selection.bufnr, {force = true})
--     end
--   end
-- end

custom_actions.delete_buffer = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:delete_selection(function(selection)
    vim.api.nvim_buf_delete(selection.bufnr, { force = true })
  end)
end

custom_actions.remove_current_selection = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:delete_selection()
end

-- Reset the prompt keeping the cursor at the current entry in the results window.
custom_actions.reset_prompt = function(prompt_bufnr)
  action_state.get_current_picker(prompt_bufnr):reset_prompt()
end

-- Simple previewer to set the current content value in the preview window
-- with 'wrap' turned on. This is used in command_history where the commands
-- could get pretty long and the entire command will be previewed similar
-- to fzf.
local function wrap_previewer()
  return require("telescope.previewers").new_buffer_previewer({
    get_buffer_by_name = function(_, entry)
      return entry.value
    end,
    define_preview = function(self, entry, status)
      vim.api.nvim_win_set_option(status.preview_win, "wrap", true)
      vim.api.nvim_buf_set_lines(
        self.state.bufnr,
        0,
        -1,
        false,
        { "  " .. entry.value }
      )
    end,
  })
end

require("telescope").setup({
  defaults = {
    prompt_prefix = require("core.icons").telescope .. " ",
    selection_caret = "❯ ",
    prompt_position = "top",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    color_devicons = true,
    winblend = vim.g.window_blend,
    file_ignore_patterns = { "__pycache__", ".mypy_cache" },
    layout_defaults = {
      horizontal = {
        preview_width = 0.55,
        width_padding = 0.05,
        height_padding = 0.1,
      },
      vertical = {
        preview_height = 0.5,
        width_padding = 0.1,
        height_padding = 0.06,
        mirror = true,
      },
    },
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-x>"] = custom_actions.remove_current_selection,
        ["<C-y>"] = custom_actions.yank_entry,
        ["<C-l>"] = custom_actions.reset_prompt,
      },
    },
  },
  extensions = {
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    arecibo = {
      selected_engine = "google",
      url_open_command = "open",
      show_http_headers = false,
      show_domain_icons = false,
    },
    bookmarks = {
      selected_browser = "brave",
      url_open_command = "open",
    },
  },
})

---Helper function to load the telescope extensions without blowing up.
---It only emits a small warning :)
---@param extensions table
local function load_telescope_extensions(extensions)
  for _, name in ipairs(extensions) do
    local ok, _ = pcall(require("telescope").load_extension, name)
    if not ok then
      utils.warn("[Telescope] Failed to load the extension: " .. name)
    end
  end
end

-- Load the extensions
load_telescope_extensions({
  "fzf",
  -- "arecibo",
  -- "bookmarks",
  "github_stars",
  -- "installed_plugins",
  -- "startify_sessions",
  -- "dirvish_cd",
})

-- Helper function to set the keymaps for telescope functions
local function tele_map(key, funcname, module)
  module = module or "plugin.telescope"
  map("n", key, '<Cmd>lua require("' .. module .. '").' .. funcname .. "()<CR>")
end

-- Meta
tele_map("<Leader>te", "builtin", "telescope.builtin")

-- Files
tele_map("<C-p>", "find_files")
tele_map("<Leader>;", "buffers")
tele_map("<C-f>", "current_buffer")
tele_map("<Leader>rp", "grep_prompt")
tele_map("<Leader>rg", "live_grep")
tele_map("<Leader>fd", "search_dotfiles")
tele_map("<Leader>fp", "installed_plugins")
tele_map("<Leader>fa", "search_all_files")

-- Git
tele_map("<Leader>gc", "git_commits", "telescope.builtin")
tele_map("<Leader>gs", "github_stars")

-- Neovim (NOTE: Use <nowait> for 'q' only keymap)
tele_map("<Leader>fh", "help_tags")
tele_map("<Leader>fm", "keymaps")
tele_map("<Leader>fc", "commands")
tele_map("<Leader>hi", "highlights")
tele_map("<Leader>fo", "vim_options")
tele_map("q:", "command_history")
tele_map("q/", "search_history")

-- Extensions
tele_map("<Leader>fb", "bookmarks")
tele_map("<Leader>fw", "arecibo")
tele_map("<Leader>fs", "startify_sessions")

-- Entrypoints which will allow me to configure each command individually.
local M = {}

---Default no previewer dropdown theme opts.
local function no_previewer()
  return themes.get_dropdown({
    width = 0.8,
    results_height = 0.8,
    previewer = false,
  })
end

---Generic function to find files in given directory.
---Also used in installed_plugins extension
function M.find_files_in_dir(dir, opts)
  opts = opts or {}
  local dir_opts = {
    prompt_title = "Find Files (" .. vim.fn.fnamemodify(dir, ":t") .. ")",
    cwd = dir,
    layout_strategy = "flex",
    layout_config = {
      flip_columns = 120,
    },
  }
  dir_opts = vim.tbl_deep_extend("force", dir_opts, opts)
  require("telescope.builtin").find_files(dir_opts)
end

function M.find_files()
  M.find_files_in_dir(utils.get_project_root())
end

function M.search_all_files()
  require("plugin.telescope").find_files_in_dir(utils.get_project_root(), {
    prompt_title = "Search All Files",
    find_command = {
      "fd",
      "--type",
      "f",
      "--hidden",
      "--follow",
      "--exclude",
      ".git",
      "--no-ignore",
    },
  })
end

function M.grep_prompt()
  require("telescope.builtin").grep_string({
    cwd = utils.get_project_root(),
    shorten_path = true,
    search = vim.fn.input("Grep String > "),
  })
end

function M.live_grep()
  require("telescope.builtin").live_grep({
    cwd = utils.get_project_root(),
    shorten_path = true,
  })
end

function M.search_dotfiles()
  M.find_files_in_dir("~/dotfiles", {
    hidden = true,
    follow = true,
    file_ignore_patterns = { ".git/" },
  })
end

function M.installed_plugins()
  require("telescope").extensions.installed_plugins.installed_plugins(themes.get_dropdown({
    width = _CachedPluginInfo.max_length + 10,
    results_height = 0.8,
    previewer = false,
  }))
end

function M.startify_sessions()
  require("telescope").extensions.startify_sessions.startify_sessions(themes.get_dropdown({
    width = 40,
    results_height = 0.5,
    previewer = false,
  }))
end

function M.help_tags()
  require("telescope.builtin").help_tags({
    layout_config = {
      preview_width = 0.65,
      width_padding = 0.10,
    },
  })
end

function M.highlights()
  require("telescope.builtin").highlights({
    layout_config = {
      preview_width = 0.65,
      width_padding = 0.10,
    },
  })
end

function M.current_buffer()
  require("telescope.builtin").current_buffer_fuzzy_find(no_previewer())
end

function M.vim_options()
  require("telescope.builtin").vim_options(no_previewer())
end

function M.keymaps()
  require("telescope.builtin").keymaps(no_previewer())
end

function M.commands()
  require("telescope.builtin").commands(no_previewer())
end

function M.command_history()
  require("telescope.builtin").command_history(themes.get_ivy({
    previewer = false,
    layout_config = {
      height = math.floor(0.4 * vim.o.lines),
    },
  }))
end

function M.search_history()
  require("telescope.builtin").search_history(themes.get_ivy({
    previewer = false,
    layout_config = {
      height = math.floor(0.4 * vim.o.lines),
    },
  }))
end

-- function M.command_history()
--   require("telescope.builtin").command_history({
--     previewer = wrap_previewer(),
--     results_title = false,
--     preview_title = "Command",

--     -- 'center' does not have a layout config :(
--     layout_strategy = "vertical",
--     layout_config = {
--       preview_height = 3,
--       mirror = true,
--       width_padding = math.max(10, (vim.o.columns - 100) / 2),
--       height_padding = math.max(3, (vim.o.lines - 30) / 2),
--     },
--   })
-- end

-- function M.search_history()
--   require("telescope.builtin").search_history(themes.get_dropdown({
--     width = math.min(100, vim.o.columns - 20),
--     results_height = math.min(30, vim.o.lines - 10),
--     previewer = false,
--   }))
-- end

function M.arecibo()
  require("telescope").extensions.arecibo.websearch(no_previewer())
end

function M.bookmarks()
  require("telescope").extensions.bookmarks.bookmarks(no_previewer())
end

function M.github_stars()
  require("telescope").extensions.github_stars.github_stars(no_previewer())
end

-- https://github.com/nvim-telescope/telescope.nvim/issues/621#issuecomment-802222898
-- Added the ability to delete multiple buffers in one go using multi-selection.
function M.buffers()
  require("telescope.builtin").buffers(themes.get_dropdown({
    -- sorting_strategy = 'descending',
    previewer = false,
    sort_lastused = true,
    show_all_buffers = true,
    shorten_path = false,
    width = math.min(vim.o.columns - 20, 110),

    -- Height ranges from 10 to #lines - 10 (depending on the number of buffers)
    results_height = math.max(
      10,
      math.min(vim.o.lines - 10, #vim.fn.getbufinfo({ buflisted = 1 }))
    ),

    attach_mappings = function(_, tmap)
      tmap("i", "<C-x>", custom_actions.delete_buffer)
      tmap("n", "<C-x>", custom_actions.delete_buffer)
      return true
    end,
  }))
end

return M
