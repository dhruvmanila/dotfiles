-- List of filenames which are always hidden in a oil buffer.
local always_hidden = {
  '.DS_Store',
  '.mypy_cache',
  '.pytest_cache',
  '.ruff_cache',
  '__pycache__',
}

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
      ['<C-s>'] = 'actions.select_split',
      ['<C-v>'] = 'actions.select_vsplit',
      ['<C-f>'] = 'actions.preview_scroll_down',
      ['<C-b>'] = 'actions.preview_scroll_up',
      ['~'] = {
        callback = function()
          vim.cmd.edit(vim.loop.os_homedir())
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
            stop = vim.loop.os_homedir(),
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
