local vim = vim
local g = vim.g
local fn = vim.fn
local fnamemodify = fn.fnamemodify

local gl = require('galaxyline')
local gls = gl.section
local condition = require('galaxyline.condition')
local get_icon = require("nvim-nonicons").get

local colors = {}

local palette = vim.fn['gruvbox_material#get_palette'](
  g.gruvbox_material_background, g.gruvbox_material_palette
)

-- We will extract out the gui color from the table as seen in the below comment.
for name, value in pairs(palette) do
  colors[name] = value[1]
end

-- Extract out the required icons
local normal_icon   = get_icon('vim-normal-mode')
local insert_icon   = get_icon('vim-insert-mode')
local visual_icon   = get_icon('vim-visual-mode')
local select_icon   = get_icon('vim-select-mode')
local replace_icon  = get_icon('vim-replace-mode')
local command_icon  = get_icon('vim-command-mode')
local terminal_icon = get_icon('vim-terminal-mode')
local question_icon = get_icon('question')
local lock_icon     = get_icon('lock')
local git_branch    = get_icon('git-branch')

--[[
Gruvbox-material colors reference
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

local modes = {
  n      = {normal_icon,   colors.grey2},
  no     = {question_icon, colors.grey2},
  i      = {insert_icon,   colors.bg_green},
  ic     = {insert_icon,   colors.bg_green},
  c      = {command_icon,  colors.blue},
  v      = {visual_icon,   colors.bg_red},
  V      = {visual_icon,   colors.bg_red},
  [''] = {visual_icon,   colors.bg_red},
  R      = {replace_icon,  colors.bg_yellow},
  s      = {select_icon,   colors.bg_red},
  S      = {select_icon,   colors.bg_red},
  [''] = {select_icon,   colors.bg_red},
  t      = {terminal_icon, colors.purple},
  ['r?'] = {question_icon, colors.aqua},
  rm     = {'--More',      colors.aqua},
  Rv     = {'Virtual',     colors.aqua},
  ['r']  = {'Hit-Enter',   colors.aqua},
  ['!']  = {'Shell',       colors.aqua}
}

local function mode_provider()
  local m = modes[vim.fn.mode()]
  vim.cmd('hi GalaxyViMode guifg=' .. m[2] .. ' guibg=' .. colors.bg1)
  return m[1] .. ' '  -- Icons are two width
end

local function fname_dirpath_provider(transition)
  return function()
    local path = fnamemodify(fn.bufname(), ':~:.')
    local dirpath = fn.pathshorten(fnamemodify(path, ':h:h'))
    local is_root = dirpath and #dirpath == 1

    if is_root or fn.winwidth(0) < transition then
      return ''
    else
      return dirpath .. '/'
    end
  end
end

local function fname_parent_provider(transition)
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

local function fname_file_provider()
  local file = fn.expand('%:t')
  if fn.empty(file) == 1 then
    return ''
  else
    return file
  end
end

local function file_flag_provider()
  if vim.bo.readonly == true then
    return '  ' .. lock_icon
  elseif vim.bo.modifiable then
    if vim.bo.modified then
      return '   '
    end
  end
  return ''
end

---File details provider for file encoding and file format according to the
---current window width. This is displayed only if the file encoding is not
---'utf-8' and file format is not 'unix'.
local function file_detail_provider()
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

-- For filetypes that show a short statusline like some plugins
gl.short_line_list = {}

-- For left section, the separator will be rendered on the right side of the
-- component and vice versa for the right section.
gls.left = {
  {
    Start = {
      provider = function() return '▊ ' end,
      highlight = {colors.yellow, colors.bg1}
    }
  },
  {
    ViMode = {
      provider = mode_provider,
      separator = ' ',
      separator_highlight = {'NONE', colors.bg1}
    }
  },
  {
    FileIcon = {
      provider = 'FileIcon',
      condition = condition.buffer_not_empty,
      separator = ' ',
      separator_highlight = {'NONE', colors.bg1},
      highlight = {require('galaxyline.provider_fileinfo').get_file_icon_color, colors.bg1},
    }
  },
  {
    DirPath = {
      provider = fname_dirpath_provider(100),
      condition = condition.buffer_not_empty,
      highlight = {colors.grey2, colors.bg1}
    }
  },
  {
    ParentName = {
      provider = fname_parent_provider(80),
      condition = condition.buffer_not_empty,
      highlight = {colors.green, colors.bg1}
    }
  },
  {
    FileName = {
      provider = fname_file_provider,
      condition = condition.buffer_not_empty,
      highlight = {colors.fg0, colors.bg1, 'bold'}
    }
  },
  {
    ModifiedFlag = {
      provider = file_flag_provider,
      condition = condition.buffer_not_empty,
      highlight = {colors.red, colors.bg1, 'bold'}
    }
  },
}


gls.right = {
  {
    FileDetail = {
      provider = file_detail_provider,
      highlight = {colors.grey2, colors.bg1, 'bold'},
    }
  },
  {
    LineInfo = {
      provider = 'LineColumn',
      separator = ' ',
      separator_highlight = {'NONE', colors.bg1},
      highlight = {colors.grey2, colors.bg1, 'bold'},
    },
  },
  {
    GitIcon = {
      provider = function() return git_branch end,
      separator = ' ',
      separator_highlight = {'NONE', colors.bg1},
      condition = condition.check_git_workspace,
      highlight = {colors.blue, colors.bg1},
    }
  },
  {
    GitBranch = {
      provider = 'GitBranch',
      separator = ' ',
      separator_highlight = {'NONE', colors.bg1},
      condition = condition.check_git_workspace,
      highlight = {colors.blue, colors.bg1 ,'bold'},
    }
  },
  {
    DiffAdd = {
      provider = 'DiffAdd',
      condition = condition.hide_in_width,
      icon = get_icon('diff-added') .. ' ',
      highlight = {colors.green,colors.bg1},
    }
  },
  {
    DiffModified = {
      provider = 'DiffModified',
      condition = condition.hide_in_width,
      icon = get_icon('diff-modified') .. ' ',
      highlight = {colors.blue,colors.bg1},
    }
  },
  {
    DiffRemove = {
      provider = 'DiffRemove',
      condition = condition.hide_in_width,
      icon = get_icon('diff-removed') .. ' ',
      highlight = {colors.red,colors.bg1},
    }
  },
  -- TODO: Update the end section accoding to what will be the second last section
  -- TODO: Does the second last section provide a whitespace at the end?
  {
    End = {
      provider = function() return '' end,
      highlight = {colors.yellow, colors.bg1},
    }
  }
}
