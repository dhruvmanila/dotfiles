local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local previewers = require 'telescope.previewers'
local putils = require 'telescope.previewers.utils'
local telescope_config = require('telescope.config').values
local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'

local float = require 'lir.float'
local lir = require 'lir'

-- This flag is used to determine whether we were in a normal buffer or in a
-- floating lir window and take the appropriate action when pressing '<CR>'.
local state = { lir_is_float = false }

-- Action to open a dirvish buffer in the currently selected directory, thus
-- replacing the opened dirvish buffer.
---@param prompt_bufnr number
local function open_dir_in_lir(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local dir = selection.cwd .. selection.value
  if state.lir_is_float then
    float.toggle(dir)
  else
    vim.cmd('edit ' .. dir)
  end
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
      vim.api.nvim_win_set_option(status.preview_win, 'signcolumn', 'yes:1')
      return putils.job_maker(
        { 'tree', '--dirsfirst', '--noreport', entry.value },
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
-- Default action (<CR>) will open lir buffer/floating window with the selected
-- directory replacing the current one.
---@param opts table
---@return nil
return function(opts)
  opts = opts or {}

  if vim.bo.filetype ~= 'lir' then
    dm.notify('Telescope', 'Not in a lir buffer', 3)
    return nil
  end

  local cwd = vim.fn.fnamemodify(lir.get_context().dir, ':~')
  if cwd == '/' or cwd == '~/' then
    dm.notify('Telescope', 'Searching from root or home is expensive', 3)
    return nil
  end

  -- Always reset the flag
  state.lir_is_float = false

  -- Close the current lir floating window
  if vim.w.lir_is_float then
    state.lir_is_float = true
    float.toggle()
  end

  pickers
    .new(opts, {
      prompt_title = 'Lir cd (' .. cwd .. ')',
      finder = finders.new_oneshot_job({ 'fd', '--type', 'd' }, {
        cwd = cwd,
        entry_maker = function(line)
          return {
            display = line,
            value = line,
            cwd = cwd,
            ordinal = line,
          }
        end,
      }),
      previewer = tree_previewer(),
      sorter = telescope_config.generic_sorter(opts),
      attach_mappings = function()
        actions.select_default:replace(open_dir_in_lir)
        return true
      end,
    })
    :find()
end
