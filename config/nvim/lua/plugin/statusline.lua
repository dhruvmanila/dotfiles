local vim = vim
local g = vim.g
local fn = vim.fn
local contains = vim.tbl_contains
local expand = fn.expand
local fnamemodify = fn.fnamemodify
local winwidth = fn.winwidth
local gl = require('galaxyline')
local gls = gl.section
local fileinfo = require('galaxyline.provider_fileinfo')
local temp_icons = require('core.icons').icons
local spinner_frames = require('core.icons').spinner_frames
local lsp_messages = require('lsp-status').messages

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

-- local colors = {
--   active_bg = '',
--   inactive_bg = '',
--   active_grey = '',
--   inactive_grey = '',
--   fg = '',
--   red = '',
--   green = '',
--   blue = '',
--   yellow = '',
--   orange = '',
--   purple = '',
--   aqua = ''
-- }

local colors = {}
local icons = {}

local palette = vim.fn['gruvbox_material#get_palette'](
  g.gruvbox_material_background, g.gruvbox_material_palette
)

-- We will extract out the gui color from the table as seen in the above comment.
for name, value in pairs(palette) do colors[name] = value[1] end

-- Colors taken out to make the names standard.
colors.fg = palette.fg0[1]
colors.active_bg = palette.bg_statusline2[1]
colors.inactive_bg = palette.bg1[1]
colors.active_grey = palette.grey2[1]
colors.inactive_grey = palette.grey0[1]

-- All icons are of 2 character wide.
for k, v in pairs(temp_icons) do icons[k] = v .. ' ' end

-- Information about the special buffers usually from the plugin filetypes.
-- TODO(buftype): quickfix, terminal
-- TODO(filetype): git
local special_buffer_info = {
  list = {
    'help',
    'tsplayground',
    'NvimTree',
    'dirvish',
    'fugitive',
    'startify',
    'packer',
  },
  name = {
    help         = function() return 'help [' .. expand('%:t:r') .. ']' end,
    tsplayground = 'TSPlayground',
    NvimTree     = 'NvimTree',
    dirvish      = function() return expand('%:~') end,
    fugitive     = 'Fugitive',
    startify     = 'Startify',
    packer       = 'Packer',
  },
  icon = {
    help         = icons.info,
    tsplayground = icons.tree,
    NvimTree     = icons.directory,
    dirvish      = icons.directory,
    fugitive     = icons.git_logo,
    startify     = '',
    packer       = icons.package,
  },
  color = {
    help         = colors.yellow,
    tsplayground = colors.green,
    NvimTree     = colors.blue,
    dirvish      = colors.blue,
    fugitive     = colors.yellow,
    startify     = 'NONE',
    packer       = colors.aqua,
  },
}

-- Mode table containing of the respective icon and color for the mode.
local modes = {
  n      = {'NORMAL', colors.grey2},
  no     = {'N·OP', colors.grey2},
  i      = {'INSERT', colors.bg_green},
  ic     = {'I·COMPL', colors.bg_green},
  c      = {'COMMAND', colors.blue},
  v      = {'VISUAL', colors.bg_red},
  V      = {'V·LINE', colors.bg_red},
  [''] = {'V·BLOCK', colors.bg_red},
  s      = {'SELECT', colors.bg_red},
  S      = {'S·LINE', colors.bg_red},
  [''] = {'S·BLOCK', colors.bg_red},
  R      = {'REPLACE', colors.bg_yellow},
  Rv     = {'V·REPLACE', colors.bg_yellow},
  ['r']  = {'PROMPT', colors.aqua},
  ['r?'] = {'CONFIRM', colors.aqua},
  rm     = {'MORE', colors.aqua},
  ['!']  = {'SHELL', colors.aqua},
  t      = {'TERMINAL', colors.purple},
}

---LSP server name aliases (displayed in the LSP messages)
local aliases = {
  pyright = 'Pyright',
  bash_ls = 'Bash LS',
  sumneko_lua = 'Sumneko',
}

---Limits for responsive statusline
local dirpath_cutoff = 15
local dirpath_limit = 100
local file_detail_limit = 120
local parent_limit = 80
local git_diff_limit = 100

---Conditions:

---Are we in the special buffer?
local function special_buffer()
  return contains(special_buffer_info.list, vim.bo.filetype)
end

---Are we not in the special buffer?
local function not_special_buffer() return not special_buffer() end


---Providers:

---Mode provider for the statusline. Returns the respective mode icon.
---@return string
local function mode_provider()
  local m = modes[vim.fn.mode()]
  vim.cmd('hi GalaxyViMode guifg=' .. m[2] .. ' guibg=' .. colors.active_bg .. ' gui=bold')
  return m[1] .. ' '
end

---File icon information provider.
---Returns either the appropriate icon or the color as per the field provided.
---default_func argument is the function to call if the current buffer filetype
---is not found in the 'field' value of 'special_buffer_info'.
---
---@param field string (icon|color)
---@param default_func function
local function file_icon_info(field, default_func)
  if field ~= 'icon' and field ~= 'color' then
    print("Invalid 'field' value for file_icon_info provider")
    return function() return '' end
  end
  return function()
    if special_buffer() then
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
---@param cutoff integer string length after which only the tail part is returned
---@return function
local function dirpath_provider(transition, cutoff)
  return function()
    local path = expand('%:~:.')
    local dirpath = fn.pathshorten(fnamemodify(path, ':h:h'))
    local len = #dirpath
    local is_root = dirpath and len == 1

    if not is_root and winwidth(0) > transition then
      if len > cutoff then
        return '../' .. fnamemodify(dirpath, ':t') .. '/'
      else
        return dirpath .. '/'
      end
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
    local parent = expand('%:~:.:h:t')
    local is_root = parent and #parent == 1
    if not is_root and winwidth(0) > transition then
      return parent .. '/'
    end
  end
end

---Filename provider.
---Returns the name of the file when in an active window otherwise the entire
---path to the file.
---
---@param active boolean
---@return string
local function filename_provider(active)
  return function()
    if special_buffer() then
      return ''
    elseif active then
      return expand('%:t') .. ' '
    else
      return expand('%:~:.') .. ' '
    end
  end
end

-- File flags provider.
-- Returns the appropriate flag for the current window file.
-- Supported flags: Readonly, modified.
local function file_flags()
  if vim.bo.readonly == true then
    return ' ' .. icons.lock
  elseif vim.bo.modifiable then
    if vim.bo.modified then return ' ' .. icons.pencil end
  end
end

-- File details provider.
-- Returns the file encoding and file format according to the current window
-- width. This is displayed only if the file encoding is not 'utf-8' and
-- file format is not 'unix'.
local function file_detail()
  local encode = vim.bo.fenc ~= '' and vim.bo.fenc or vim.o.enc
  local format = vim.bo.fileformat

  if winwidth(0) > file_detail_limit then
    return encode:upper() .. ' ' .. format:upper() .. ' '
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
end

---Git status info provider using the gitsigns plugin.
---@param field string (head|added|changed|removed)
---@return string|nil
local function git_status_info(field)
  return function()
    local status_dict = vim.b.gitsigns_status_dict
    if status_dict ~= nil then
      local info = status_dict[field]
      if info ~= nil then
        if type(info) == 'number' then
          if info > 0 and winwidth(0) > git_diff_limit then
            return info .. ' '
          end
        elseif string.len(info) > 0 then
          return info .. ' '
        end
      end
    end
  end
end

---Neovim LSP diagnostics count provider
---@param severity string (Error|Warning|Hint|Information)
---@return function
local function get_lsp_diagnostics(severity)
  return function()
    local count = vim.lsp.diagnostic.get_count(vim.api.nvim_get_current_buf(), severity)
    if count ~= 0 then return count .. ' ' end
  end
end

---Neovim LSP current function provider
---@return string|nil
local function get_lsp_current_function()
  local current_function = vim.b.lsp_current_function
  if current_function and current_function ~= '' then
    return '(' .. current_function .. ')'
  end
end


---Neovim LSP messages
---Ref: https://github.com/nvim-lua/lsp-status.nvim/blob/master/lua/lsp-status/statusline.lua#L37
---@return string|nil
local function get_lsp_messages()
  local messages = lsp_messages()
  local msgs = {}

  for _, msg in ipairs(messages) do
    local name = aliases[msg.name] or msg.name
    local client_name = '[' .. name .. ']'
    local contents
    if msg.progress then
      contents = msg.title
      if msg.message then contents = contents .. ' ' .. msg.message end
      if msg.percentage then contents = contents .. '(' .. msg.percentage .. ')' end
      if msg.spinner then
        contents = spinner_frames[(msg.spinner % #spinner_frames) + 1] .. ' ' .. contents
      end
    elseif msg.status then
      contents = msg.content
      if msg.uri then
        local filename = vim.uri_to_fname(msg.uri)
        filename = fnamemodify(filename, ':~:.')
        local space = math.min(60, math.floor(0.6 * winwidth(0)))
        if #filename > space then filename = vim.fn.pathshorten(filename) end
        contents = '(' .. filename .. ') ' .. contents
      end
    else
      contents = msg.content
    end
    table.insert(msgs, client_name .. ' ' .. contents)
  end

  local status = vim.trim(table.concat(msgs, ' '))
  if status ~= '' then return status .. ' ' end
end

-- This should be set to an empty string list as this variable is used by
-- galaxyline to determine which buffers should display the short line. But,
-- we are using the short line to display the inactive statusline for all
-- types of buffers.
gl.short_line_list = {''}

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
    }
  },
  {
    FileIcon = {
      provider = file_icon_info('icon', fileinfo.get_file_icon),
      highlight = {
        file_icon_info('color', fileinfo.get_file_icon_color) , colors.active_bg
      },
    }
  },
  {
    DirPath = {
      provider = dirpath_provider(dirpath_limit, dirpath_cutoff),
      condition = not_special_buffer,
      highlight = {colors.active_grey, colors.active_bg}
    }
  },
  {
    ParentName = {
      provider = parent_dir(parent_limit),
      condition = not_special_buffer,
      highlight = {colors.green, colors.active_bg, 'bold'}
    }
  },
  {
    FileName = {
      provider = filename_provider(true),
      highlight = {colors.fg, colors.active_bg, 'bold'}
    }
  },
  {
    FileFlags = {
      provider = file_flags,
      condition = not_special_buffer,
      highlight = {colors.red, colors.active_bg, 'bold'},
    },
  },
  {
    TruncationPoint = {
      provider = {},
      separator = '%<',
    }
  },
  {
    SpecialBufferName = {
      provider = special_buffer_name,
      highlight = {colors.fg, colors.active_bg}
    }
  },
  {
    LspCurrentFunction = {
      provider = get_lsp_current_function,
      condition = not_special_buffer,
      highlight = {colors.active_grey, colors.active_bg}
    }
  }
}

gls.mid = {
  {
    DiagnosticInfo = {
      provider = get_lsp_diagnostics('Information'),
      condition = not_special_buffer,
      icon = icons.info,
      highlight = {colors.blue, colors.active_bg},
    }
  },
  {
    DiagnosticHint = {
      provider = get_lsp_diagnostics('Hint'),
      condition = not_special_buffer,
      icon = icons.hint,
      highlight = {colors.aqua, colors.active_bg},
    }
  },
  {
    DiagnosticWarn = {
      provider = get_lsp_diagnostics('Warning'),
      condition = not_special_buffer,
      icon = icons.warning,
      highlight = {colors.yellow, colors.active_bg},
    }
  },
  {
    DiagnosticError = {
      provider = get_lsp_diagnostics('Error'),
      condition = not_special_buffer,
      icon = icons.error,
      highlight = {colors.red, colors.active_bg},
    },
  },
}

gls.right = {
  {
    LineInfo = {
      provider = 'LineColumn',
      condition = not_special_buffer,
      highlight = {colors.active_grey, colors.active_bg, 'bold'},
    },
  },
  {
    FileDetail = {
      provider = file_detail,
      condition = not_special_buffer,
      separator = ' ',
      separator_highlight = {'NONE', colors.active_bg},
      highlight = {colors.active_grey, colors.active_bg, 'bold'},
    }
  },
  {
    GitBranch = {
      provider = git_status_info('head'),
      condition = not_special_buffer,
      icon = icons.git_branch,
      highlight = {colors.blue, colors.active_bg, 'bold'},
    }
  },
  {
    DiffAdd = {
      provider = git_status_info('added'),
      condition = not_special_buffer,
      icon = icons.diff_added,
      highlight = {colors.green, colors.active_bg},
    }
  },
  {
    DiffModified = {
      provider = git_status_info('changed'),
      condition = not_special_buffer,
      icon = icons.diff_modified,
      highlight = {colors.blue, colors.active_bg},
    }
  },
  {
    DiffRemove = {
      provider = git_status_info('removed'),
      condition = not_special_buffer,
      icon = icons.diff_removed,
      highlight = {colors.red, colors.active_bg},
    },
  },
  {
    LspMessages = {
      provider = get_lsp_messages,
      condition = not_special_buffer,
      highlight = {colors.bg0, colors.grey2}
    }
  }
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
      highlight = {colors.inactive_grey, colors.inactive_bg}
    }
  },
  {
    TruncationPoint = {
      provider = {},
      separator = '%<',
    }
  },
  {
    InactiveSpecialBufferName = {
      provider = special_buffer_name,
      highlight = {colors.inactive_grey, colors.inactive_bg}
    }
  },
  {
    InactiveFileName = {
      provider = filename_provider(false),
      highlight = {colors.inactive_grey, colors.inactive_bg}
    }
  },
  {
    InactiveEnd = {
      provider = function() return ' ' end,
      highlight = {'NONE', colors.inactive_bg}
    }
  }
}
