-- Ref: https://github.com/mhinz/vim-startify
local g = vim.g
-- local icons = require('core.icons').icons

vim.api.nvim_set_keymap('n', '<Leader>`', '<Cmd>Startify<CR>', {noremap = true})

--- NOTE: By wrapping the header and footer into a function, we can generate the
--- respective table as per the current context.

--- Generate and return the Startify header.
---@return table
function StartifyHeader()
  return {
    '',
    '',
    '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
    '',
    '',
  }
end

--- Generate and return the Startify footer.
---@return table
function StartifyFooter()
  local loaded_plugins = 0
  for _, info in pairs(_G.packer_plugins) do
    if info.loaded then
      loaded_plugins = loaded_plugins + 1
    end
  end

  return {
    '',
    'neovim loaded ' .. loaded_plugins .. ' plugins',
    '',
  }
end

--- Set the corresponding header and footer.
g.startify_custom_header = "startify#center(luaeval('StartifyHeader()'))"
g.startify_custom_footer = "startify#center(luaeval('StartifyFooter()'))"

-- local function custom_command_set()
--   return {
--     {line = 'Help reference', cmd = 'h reference'},
--   }
-- end

-- g.startify_lists = {{type = 'commands'}, {type = custom_command_set}}

-- local commands = {
--   {l = {icons.pin .. '  Open Last Session', 'SLoad __LAST__'}},
--   {s = {icons.globe ..  '  Find Sessions', "lua require('plugin.telescope').startify_sessions()"}},
--   {h = {icons.history .. '  Recently Opened Files', 'Telescope oldfiles'}},
--   {f = {icons.file .. '  Find Files', "lua require('plugin.telescope').find_files()"}},
--   {p = {icons.stopwatch .. '  StartupTime', 'StartupTime'}},
-- }

-- local max_length = 0
-- for _, v in ipairs(commands) do
--   for _, c in pairs(v) do
--     max_length = math.max(max_length, type(c) == 'table' and #c[1] or #c)
--   end
-- end

-- g.startify_commands = commands
-- g.startify_center = max_length + 5

g.startify_session_before_save = {
  'let $CURRENT_TABPAGE = tabpagenr()',
  'silent! tabdo NvimTreeClose',
  'execute $CURRENT_TABPAGE . "tabnext"',
}

g.startify_fortune_use_unicode = 1

g.startify_session_persistence = 1
g.startify_session_delete_buffers = 1

g.startify_change_to_dir = 0
g.startify_change_to_vcs_root = 0
