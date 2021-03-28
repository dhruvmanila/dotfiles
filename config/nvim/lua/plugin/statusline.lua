local vim = vim
local g = vim.g
local fn = vim.fn
local expand = fn.expand
local fnamemodify = fn.fnamemodify
local gl = require('galaxyline')
local gls = gl.section
local condition = require('galaxyline.condition')
local fileinfo = require('galaxyline.provider_fileinfo')
local get_icon = require("nvim-nonicons").get
local contains = vim.tbl_contains

--[[
Gruvbox-material colors reference:
Background: 'medium'
Palette:    'mix'
NOTE: Change the colors if either the background or palette changes.
{
  aqua             = { "#8bba7f", "108"  },
  bg0              = { "#282828", "235"  },
  bg1              = { "#32302f", "236"  },
  bg2              = { "#32302f", "236"  },
  bg3              = { "#45403d", "237"  },
  bg4              = { "#45403d", "237"  },
  bg5              = { "#5a524c", "239"  },
  bg_current_word  = { "#3c3836", "237"  },
  bg_diff_blue     = { "#0e363e", "17"   },
  bg_diff_green    = { "#34381b", "22"   },
  bg_diff_red      = { "#402120", "52"   },
  bg_green         = { "#b0b846", "142"  },
  bg_red           = { "#db4740", "167"  },
  bg_statusline1   = { "#32302f", "236"  },
  bg_statusline2   = { "#3a3735", "236"  },
  bg_statusline3   = { "#504945", "240"  },
  bg_visual_blue   = { "#374141", "17"   },
  bg_visual_green  = { "#3b4439", "22"   },
  bg_visual_red    = { "#4c3432", "52"   },
  bg_visual_yellow = { "#4f422e", "94"   },
  bg_yellow        = { "#e9b143", "214"  },
  blue             = { "#80aa9e", "109"  },
  fg0              = { "#e2cca9", "223"  },
  fg1              = { "#e2cca9", "223"  },
  green            = { "#b0b846", "142"  },
  grey0            = { "#7c6f64", "243"  },
  grey1            = { "#928374", "245"  },
  grey2            = { "#a89984", "246"  },
  orange           = { "#f28534", "208"  },
  purple           = { "#d3869b", "175"  },
  red              = { "#f2594b", "167"  },
  yellow           = { "#e9b143", "214"  }
  none             = { "NONE",    "NONE" },
}
--]]

local colors = {}
local palette = vim.fn['gruvbox_material#get_palette'](
  g.gruvbox_material_background, g.gruvbox_material_palette
)

-- We will extract out the gui color from the table as seen in the above comment.
for name, value in pairs(palette) do
  colors[name] = value[1]
end

-- Colors taken out to make the names standard.
colors.fg = palette.fg0[1]
colors.active_bg = palette.bg_statusline2[1]
colors.inactive_bg = palette.bg1[1]
colors.active_grey = palette.grey2[1]
colors.inactive_grey = palette.grey0[1]

-- Extract out the required icons.
local icons = {
  normal        = get_icon('vim-normal-mode'),
  insert        = get_icon('vim-insert-mode'),
  visual        = get_icon('vim-visual-mode'),
  select        = get_icon('vim-select-mode'),
  replace       = get_icon('vim-replace-mode'),
  command       = get_icon('vim-command-mode'),
  terminal      = get_icon('vim-terminal-mode'),
  question      = get_icon('question'),
  lock          = get_icon('lock'),
  info          = get_icon('info'),
  git_branch    = get_icon('git-branch'),
  diff_added    = get_icon('diff-added'),
  diff_modified = get_icon('diff-modified'),
  diff_removed  = get_icon('diff-removed'),
  directory     = get_icon('file-directory'),
}

-- Information about the special buffers usually from the plugin filetypes.
local special_buffer_info = {
  list = {
    'help',
    'tsplayground',
    'NvimTree',
    'dirvish',
    'fugitive',
    'startify',
  },
  name = {
    help         = function() return 'help [' .. expand('%:t') .. ']' end,
    tsplayground = 'TSPlayground',
    NvimTree     = 'NvimTree',
    dirvish      = vim.fn.bufname,
    fugitive     = 'Fugitive',
    startify     = 'Startify'
  },
  icon = {
    help         = icons.info,
    tsplayground = '侮',
    NvimTree     = icons.directory,
    dirvish      = icons.directory,
    fugitive     = '',
    startify     = '',
  },
  color = {
    help         = colors.yellow,
    tsplayground = colors.green,
    NvimTree     = colors.blue,
    dirvish      = colors.blue,
    fugitive     = colors.yellow,
    startify     = 'NONE',
  }
}

-- Mode table containing of the respective icon and color for the mode.
local modes = {
  n      = {icons.normal,   colors.grey2},
  no     = {icons.question, colors.grey2},
  i      = {icons.insert,   colors.bg_green},
  ic     = {icons.insert,   colors.bg_green},
  c      = {icons.command,  colors.blue},
  v      = {icons.visual,   colors.bg_red},
  V      = {icons.visual,   colors.bg_red},
  [''] = {icons.visual,   colors.bg_red},
  R      = {icons.replace,  colors.bg_yellow},
  s      = {icons.select,   colors.bg_red},
  S      = {icons.select,   colors.bg_red},
  [''] = {icons.select,   colors.bg_red},
  t      = {icons.terminal, colors.purple},
  ['r?'] = {icons.question, colors.aqua},
  rm     = {'--More',       colors.aqua},
  Rv     = {'Virtual',      colors.aqua},
  ['r']  = {'Hit-Enter',    colors.aqua},
  ['!']  = {'Shell',        colors.aqua}
}

---Limits for responsive statusline
local dirpath_limit = 100
local dirpath_cutoff = 15
local parent_limit = 80
local git_diff_limit = 70

---Providers:

---Mode provider for the statusline. Returns the respective mode icon.
---@return string
local function mode_provider()
  local m = modes[vim.fn.mode()]
  vim.cmd('hi GalaxyViMode guifg=' .. m[2] .. ' guibg=' .. colors.active_bg)
  return m[1] .. ' '  -- Icons are two width
end

---File icon information provider.
---Returns either the appropriate icon or the color as per the field provided.
---default_func argument is the function to call if the current buffer filetype
---is not found in the 'field' value of 'special_buffer_info'.
---
---@param field string ['icon', 'color']
---@param default_func function
local function file_icon_info(field, default_func)
  if field ~= 'icon' and field ~= 'color' then
    print("Invalid 'field' value for file_icon_info provider")
    return function() return '' end
  end
  return function()
    if contains(special_buffer_info.list, vim.bo.filetype) then
      return special_buffer_info[field][vim.bo.filetype]
    end
    return default_func()
  end
end

-- Filename directory path provider.
-- A responsive provider which returns the path to current files directory in
-- which each directory is shortened except for the tail directory. A maximum
-- of cutoff characters are allowed after which only the tail directory is
-- returned. If the window width becomes less than transition, the provider
-- returns an empty string.
--
---@param transition integer window width upto which to return the path
---@param cutoff integer window width after which only the tail part is returned
---@return function
local function dirpath_provider(transition, cutoff)
  return function()
    local path = fnamemodify(fn.bufname(), ':~:.')
    local dirpath = fn.pathshorten(fnamemodify(path, ':h:h'))
    local len = #dirpath
    local is_root = dirpath and len == 1

    if is_root or fn.winwidth(0) < transition then
      return ''
    elseif len > cutoff then
      return '../' .. fnamemodify(dirpath, ':t') .. '/'
    else
      return dirpath .. '/'
    end
  end
end

-- Filename parent directory provider.
-- Returns the current file directory name if the window width is not less than
-- the transition value.
--
---@param transition integer window width upto which to return the path
---@return function
local function parent_dir(transition)
  return function()
    local parent = fnamemodify(fn.bufname(), ':~:.:h:t')
    local is_root = parent and #parent == 1
    if is_root or fn.winwidth(0) < transition then
      return ''
    else
      return parent .. '/'
    end
  end
end

-- File flags provider.
-- Returns the appropriate flag for the current window file.
-- Supported flags: Readonly, modified.
local function file_flags()
  if vim.bo.readonly == true then
    return '  ' .. icons.lock
  elseif vim.bo.modifiable then
    if vim.bo.modified then
      return '   '
    end
  end
  return ''
end

-- File details provider.
-- Returns the file encoding and file format according to the current window
-- width. This is displayed only if the file encoding is not 'utf-8' and
-- file format is not 'unix'.
local function file_detail()
  local encode = vim.bo.fenc ~= '' and vim.bo.fenc or vim.o.enc
  local format = vim.bo.fileformat

  if vim.fn.winwidth(0) < 80 then
    return ''
  else
    if encode == 'utf-8' then encode = '' end
    if format == 'unix' then format = '' end
    if encode == '' and format == '' then
      return ''
    else
      return encode:upper() .. ' ' .. format:upper()
    end
  end
end

---Special buffer name provider.
---Returns the name of the special buffer as per the name table values of
---the special_buffer_info variable.
local function special_buffer_name()
  local info = special_buffer_info.name[vim.bo.filetype]
  if type(info) == 'function' then
    return info()
  elseif info ~= nil then
    return info
  end
  return ''
end

-- Conditions:

---Are we in the special buffer?
local function special_buffer()
  return contains(special_buffer_info.list, vim.bo.filetype)
end

---Are we not in the special buffer?
local function not_special_buffer()
  return not special_buffer()
end

---Are we not in the special buffer and is the buffer not emoty?
local function not_special_buffer_and_buffer_not_empty()
  return not_special_buffer() and condition.buffer_not_empty()
end

---Are we not in the special buffer and are we in a git workspace?
local function not_special_buffer_and_check_git_workspace()
  return not_special_buffer() and condition.check_git_workspace()
end

---Are we not in the special buffer and window width is less than limit?
---@param limit integer
local function not_special_buffer_and_check_winwidth(limit)
  return function()
    return not_special_buffer() and fn.winwidth(0) > limit
  end
end

-- This should be set to an empty string list as this variable is used by
-- galaxyline to determine which buffers should display the short line. But,
-- we are using the short line to display the inactive statusline for all
-- types of buffers.
gl.short_line_list = {""}

-- For left section, the separator will be rendered on the right side of the
-- component and vice versa for the right section.
gls.left = {
  {
    ActiveStart = {
      provider = function() return '▊ ' end,
      highlight = {colors.yellow, colors.active_bg}
    }
  },
  {
    ViMode = {
      provider = mode_provider,
      condition = not_special_buffer,
      separator = ' ',
      separator_highlight = {'NONE', colors.active_bg}
    }
  },
  {
    FileIcon = {
      provider = file_icon_info('icon', fileinfo.get_file_icon),
      separator = ' ',
      separator_highlight = {'NONE', colors.active_bg},
      highlight = {
        file_icon_info('color', fileinfo.get_file_icon_color) , colors.active_bg
      },
    }
  },
  {
    DirPath = {
      provider = dirpath_provider(dirpath_limit, dirpath_cutoff),
      condition = not_special_buffer_and_buffer_not_empty,
      highlight = {colors.active_grey, colors.active_bg}
    }
  },
  {
    ParentName = {
      provider = parent_dir(parent_limit),
      condition = not_special_buffer_and_buffer_not_empty,
      highlight = {colors.green, colors.active_bg}
    }
  },
  {
    FileName = {
      provider = function() return expand('%:t') end,
      condition = not_special_buffer_and_buffer_not_empty,
      highlight = {colors.fg, colors.active_bg, 'bold'}
    }
  },
  {
    SpecialBufferName = {
      provider = special_buffer_name,
      condition = special_buffer,
      highlight = {colors.fg, colors.active_bg}
    }
  },
  {
    FileFlags = {
      provider = file_flags,
      condition = not_special_buffer_and_buffer_not_empty,
      highlight = {colors.red, colors.active_bg, 'bold'}
    }
  },
}


gls.right = {
  {
    FileDetail = {
      provider = file_detail,
      condition = not_special_buffer,
      highlight = {colors.fg, colors.active_bg, 'bold'},
    }
  },
  {
    LineInfo = {
      provider = 'LineColumn',
      condition = not_special_buffer,
      separator = ' ',
      separator_highlight = {'NONE', colors.active_bg},
      highlight = {colors.fg, colors.active_bg, 'bold'},
    },
  },
  {
    GitBranch = {
      provider = 'GitBranch',
      condition = not_special_buffer_and_check_git_workspace,
      separator = ' ',
      separator_highlight = {'NONE', colors.active_bg},
      icon = icons.git_branch .. ' ',
      highlight = {colors.blue, colors.active_bg ,'bold'},
    }
  },
  {
    DiffAdd = {
      provider = 'DiffAdd',
      condition = not_special_buffer_and_check_winwidth(git_diff_limit),
      icon = icons.diff_added .. ' ',
      highlight = {colors.green, colors.active_bg},
    }
  },
  {
    DiffModified = {
      provider = 'DiffModified',
      condition = not_special_buffer_and_check_winwidth(git_diff_limit),
      icon = icons.diff_modified .. ' ',
      highlight = {colors.blue, colors.active_bg},
    }
  },
  {
    DiffRemove = {
      provider = 'DiffRemove',
      condition = not_special_buffer_and_check_winwidth(git_diff_limit),
      icon = icons.diff_removed .. ' ',
      highlight = {colors.red, colors.active_bg},
    }
  },
  -- TODO: Does the second last section provide a whitespace at the end?
  -- {
  --   ActiveEnd = {
  --     provider = function() return '' end,
  --     highlight = {colors.yellow, colors.active_bg},
  --   }
  -- }
}

-- Used as the inactive statusline
gls.short_line_left = {
  {
    InactiveStart = {
      provider = function() return '▊ ' end,
      highlight = {colors.inactive_grey, colors.inactive_bg}
    }
  },
  {
    InactiveFileIcon = {
      provider = file_icon_info('icon', fileinfo.get_file_icon),
      condition = condition.buffer_not_empty,
      separator = ' ',
      separator_highlight = {'NONE', colors.inactive_bg},
      highlight = {colors.inactive_grey, colors.inactive_bg},
    }
  },
  {
    InactiveSpecialBufferName = {
      provider = special_buffer_name,
      condition = special_buffer,
      highlight = {colors.inactive_grey, colors.inactive_bg}
    }
  },
  {
    InactiveFileName = {
      provider = function() return expand('%') end,
      condition = not_special_buffer,
      separator = ' ',
      separator_highlight = {'NONE', colors.inactive_bg},
      highlight = {colors.inactive_grey, colors.inactive_bg}
    }
  },
}
