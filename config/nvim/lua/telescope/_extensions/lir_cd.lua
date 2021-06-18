local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local putils = require "telescope.previewers.utils"
local config = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"

local lir = require "lir"
local float = require "lir.float"
local warn = require("dm.utils").warn

-- Action to open a dirvish buffer in the currently selected directory, thus
-- replacing the opened dirvish buffer.
---@param prompt_bufnr number
local function open_dir_in_lir(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local dir = selection.cwd .. selection.value
  float.toggle(P(dir))
end

-- Telescope previewer to preview the tree for the given directory.
-- This uses the suggested `previewers.utils.job_maker` function to display
-- the output of `tree` command in the preview buffer.
local function tree_previewer()
  return previewers.new_buffer_previewer {
    get_buffer_by_name = function(_, entry)
      return entry.value
    end,
    define_preview = function(self, entry, status)
      vim.api.nvim_win_set_option(status.preview_win, "signcolumn", "yes:1")
      return putils.job_maker(
        { "tree", "--dirsfirst", "--noreport", entry.value },
        self.state.bufnr,
        {
          value = entry.value,
          bufname = self.state.bufname,
          cwd = entry.cwd,
        }
      )
    end,
  }
end

-- This extension is for Lir plugin and will work only when invoked from
-- within a lir buffer. It will show all the directories from the current
-- working directory with a preview containing the tree for that directory.
--
-- The extension will emit a warning when called from the root or home directory
-- as that can be expensive, although I might allow it :)
--
-- Default action (<CR>) will open a lir floating window with the selected
-- directory replacing the current dirvish buffer.
---@param opts table
---@return nil
local function lir_cd(opts)
  opts = opts or {}

  if vim.bo.filetype ~= "lir" then
    warn "[Telescope] Not in a dirvish buffer."
    return nil
  end

  local cwd = lir.get_context().dir
  if cwd == "/" or cwd == vim.loop.os_homedir() then
    warn "[Telescope] Searching from root or home is expensive."
    return nil
  end

  -- Close the current lir window
  float.toggle()

  local displayer = entry_display.create {
    separator = " ",
    items = { { remaining = true } },
  }

  local function make_display(entry)
    return displayer { entry.value }
  end

  local function entry_maker(line)
    return {
      display = make_display,
      value = line,
      cwd = cwd,
      ordinal = line,
    }
  end

  pickers.new(opts, {
    prompt_title = "Lir cd (" .. vim.fn.fnamemodify(cwd, ":~") .. ")",
    finder = finders.new_oneshot_job({ "fd", "--type", "d" }, {
      cwd = cwd,
      entry_maker = entry_maker,
    }),
    previewer = tree_previewer(),
    sorter = config.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(open_dir_in_lir)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = { lir_cd = lir_cd },
}
