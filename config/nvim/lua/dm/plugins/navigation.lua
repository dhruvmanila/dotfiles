-- List of filenames which are always hidden in a oil buffer.
local always_hidden = {
  '.DS_Store',
  '.mypy_cache',
  '.pytest_cache',
  '.ruff_cache',
  '__pycache__',
}

-- Helper function to close the oil buffer after a selection.
---@param select_opts table options to pass to `oil.select`
---@return function #function to invoke the action
local function select_close(select_opts)
  local opts = vim.tbl_extend('keep', { close = true }, select_opts)
  return function()
    require('oil').select(opts)
  end
end

return {
  'stevearc/oil.nvim',
  keys = {
    {
      '-',
      function()
        require('oil').open()
      end,
      desc = 'Open parent directory',
    },
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    delete_to_trash = dm.is_executable 'trash-put',
    columns = {
      'permissions',
      'size',
      'mtime',
      'icon',
    },
    win_options = {
      number = false,
      relativenumber = false,
      signcolumn = 'yes:1', -- For padding
      concealcursor = 'nvic',
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name)
        return vim.tbl_contains(always_hidden, name)
      end,
    },
    keymaps = {
      ['q'] = 'actions.close',
      -- ['h'] = 'actions.parent',
      -- ['l'] = 'actions.select',
      ['<C-h>'] = false, -- Keep this for window switching
      ['<C-l>'] = false, -- Keep this for window switching
      ['<C-s>'] = {
        callback = select_close { horizontal = true },
        desc = 'Open the selection in a horizontal split and close the oil buffer',
      },
      ['<C-v>'] = {
        callback = select_close { vertical = true },
        desc = 'Open the selection in a vertical split and close the oil buffer',
      },
      ['<C-t>'] = {
        callback = select_close { tab = true },
        desc = 'Open the selection in a new tab and close the oil buffer',
      },
      ['<C-f>'] = 'actions.preview_scroll_down',
      ['<C-b>'] = 'actions.preview_scroll_up',
      ['~'] = {
        callback = function()
          require('oil').open(dm.OS_HOMEDIR)
        end,
        desc = 'Goto OS home directory',
      },
      ['`'] = {
        callback = function()
          require('oil').open '/'
        end,
        desc = 'Goto OS root directory',
      },
      ['gx'] = {
        callback = function()
          local current_dir = require('oil').get_current_dir()
          if current_dir then
            vim.ui.open(current_dir)
          else
            dm.log.warn 'Unable to get the current directory'
          end
        end,
        desc = 'Open the current directory in finder',
      },
      ['gr'] = {
        callback = function()
          local oil = require 'oil'
          local current_dir = oil.get_current_dir()
          if not current_dir then
            dm.log.warn 'Unable to get the current directory'
            return
          end
          local gitdir = vim.fs.root(current_dir, '.git')
          if not gitdir then
            return
          end
          oil.open(gitdir)
        end,
        desc = 'Goto to git root directory',
      },
    },
    float = {
      border = dm.border,
    },
    preview = {
      border = dm.border,
    },
    progress = {
      border = dm.border,
    },
  },
}
