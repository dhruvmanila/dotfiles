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
      'icon',
    },
    win_options = {
      number = false,
      relativenumber = false,
      signcolumn = 'yes:1', -- For padding
      concealcursor = 'ni',
    },
    keymaps = {
      ['q'] = 'actions.close',
      ['<C-h>'] = false, -- Keep this for window switching
      ['<C-s>'] = 'actions.select_split',
      ['<C-v>'] = 'actions.select_vsplit',
      ['~'] = {
        callback = function()
          vim.cmd.edit(vim.loop.os_homedir())
        end,
        desc = 'Goto OS home directory',
      },
      ['`'] = {
        callback = function()
          vim.cmd.edit '/'
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
          local ok, util = pcall(require, 'lspconfig.util')
          if not ok then
            return
          end
          local dir = util.find_git_ancestor(vim.loop.cwd())
          if dir == nil or dir == '' then
            return
          end
          vim.cmd.edit(dir)
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
