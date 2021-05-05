-- Ref: https://github.com/mhinz/vim-startify
-- Only for session management, I have my own start screen :)
-- local g = vim.g

-- g.startify_disable_at_vimenter = 1
-- g.startify_update_oldfiles = 0

-- g.startify_session_dir = g.neovim_session_dir
-- g.startify_session_persistence = 1
-- g.startify_session_delete_buffers = 1
-- g.startify_session_autoload = 0
-- g.startify_session_sort = 0

-- g.startify_session_before_save = {
--   'let $CURRENT_TABPAGE = tabpagenr()',
--   'silent! tabdo NvimTreeClose',
--   'execute $CURRENT_TABPAGE . "tabnext"',
-- }

--vim.api.nvim_set_keymap('n', '<Leader>`', '<Cmd>Startify<CR>', {noremap = true})

----- NOTE: By wrapping the header and footer into a function, we can generate the
----- respective table as per the current context.

----- Generate and return the Startify header.
-----@return table
--function StartifyHeader()
--  local v = vim.version()
--  v = v.major .. '.' .. v.minor .. '.' .. v.patch
--  return {
--    '',
--    '',
--    '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
--    '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
--    '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
--    '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
--    '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
--    '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
--    '',
--    '                   Neovim v' .. v .. '',
--    '',
--  }
--end

----- Generate and return the Startify footer.
-----@return table
--function StartifyFooter()
--  local loaded_plugins = 0
--  for _, info in pairs(_G.packer_plugins) do
--    if info.loaded then
--      loaded_plugins = loaded_plugins + 1
--    end
--  end

--  return {
--    '',
--    'neovim loaded ' .. loaded_plugins .. ' plugins',
--    '',
--  }
--end

--g.startify_enable_special = 0

----- Set the corresponding header and footer.
--g.startify_custom_header = "startify#center(luaeval('StartifyHeader()'))"
--g.startify_custom_footer = "startify#center(luaeval('StartifyFooter()'))"

--g.startify_lists = {{type = 'commands'}}

--local commands = {
--  {l = {icons.pin .. '  Open Last Session', 'SLoad __LAST__'}},
--  {s = {icons.globe ..  '  Find Sessions', "lua require('plugin.telescope').startify_sessions()"}},
--  {h = {icons.history .. '  Recently Opened Files', 'Telescope oldfiles'}},
--  {f = {icons.file .. '  Find Files', "lua require('plugin.telescope').find_files()"}},
--  {p = {icons.stopwatch .. '  StartupTime', 'StartupTime'}},
--}

--local max_length = 0
--for _, v in ipairs(commands) do
--  for _, c in pairs(v) do
--    max_length = math.max(max_length, type(c) == 'table' and #c[1] or #c)
--  end
--end

--g.startify_commands = commands
--g.startify_center = max_length + 5

--g.startify_fortune_use_unicode = 1

--g.startify_change_to_dir = 0
--g.startify_change_to_vcs_root = 0


local function get_last_session_name()
  local session_dir = vim.fn["startify#get_session_path"]()
  local last_session_path = vim.fn.resolve(session_dir .. "/__LAST__")
  return vim.fn.fnamemodify(last_session_path, ":t")
end

vim.api.nvim_exec([[
function! StartifyEntryFormat()
  return 'entry_path'
endfunction
]], false)

function StartifyCenter(lines)
  local longest_line = 0
  for _, line in ipairs(lines) do
    longest_line = math.max(longest_line, vim.fn.strwidth(line))
  end

  for i = 1, #lines do
    local pad = math.floor((vim.fn.winwidth(0) / 2) - (longest_line / 2))
    lines[i] = string.rep(" ", pad) .. lines[i]
  end
  return lines
end
