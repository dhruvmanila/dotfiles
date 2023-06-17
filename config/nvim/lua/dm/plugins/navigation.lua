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
  return function()
    local oil = require 'oil'
    local oilwin = vim.api.nvim_get_current_win()
    oil.select(select_opts)
    vim.api.nvim_win_call(oilwin, function()
      oil.close()
    end)
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
    delete_to_trash = dm.executable 'trash-put',
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
      ['h'] = 'actions.parent',
      ['l'] = 'actions.select',
      ['<C-h>'] = false, -- Keep this for window switching
      ['<C-l>'] = false, -- Keep this for window switching
      ['<C-s>'] = select_close { horizontal = true },
      ['<C-v>'] = select_close { vertical = true },
      ['<C-t>'] = select_close { tab = true },
      ['<C-f>'] = 'actions.preview_scroll_down',
      ['<C-b>'] = 'actions.preview_scroll_up',
      ['~'] = {
        callback = function()
          vim.cmd.edit(vim.g.os_homedir)
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
          vim.fn['external#explorer'](require('oil').get_current_dir())
        end,
        desc = 'Open the current directory in finder',
      },
      ['gr'] = {
        callback = function()
          local _, gitdir = next(vim.fs.find('.git', {
            path = require('oil').get_current_dir(),
            upward = true,
            type = 'directory',
            stop = vim.g.os_homedir,
          }))
          if gitdir == nil then
            return
          end
          require('oil').open(vim.fs.dirname(gitdir))
        end,
        desc = 'Goto to git root directory',
      },
    },
    float = {
      border = dm.border[vim.g.border_style],
    },
    preview = {
      border = dm.border[vim.g.border_style],
    },
    progress = {
      border = dm.border[vim.g.border_style],
    },
  },
}
