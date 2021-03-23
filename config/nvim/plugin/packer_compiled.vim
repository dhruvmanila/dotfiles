" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
local package_path_str = "/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

_G.packer_plugins = {
  ["gruvbox.nvim"] = {
    config = { "require('plugin.colorscheme')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/gruvbox.nvim"
  },
  indentLine = {
    config = { "require('plugin.indentline')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/indentLine"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/lush.nvim"
  },
  ["nvim-tree.lua"] = {
    config = { "require('plugin.nvim_tree')" },
    keys = { { "n", "<C-n>" }, { "n", "<C-f>" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "require('plugin.treesitter')" },
    loaded = false,
    needs_bufread = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  playground = {
    commands = { "TSPlaygroundToggle" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/playground"
  },
  ["startuptime.vim"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/startuptime.vim"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-cool"] = {
    config = { "vim.g.CoolTotalMatches = 1" },
    keys = { { "", "/" }, { "", "?" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-cool"
  },
  ["vim-easy-align"] = {
    config = { "require('plugin.easy_align')" },
    keys = { { "n", "ga" }, { "x", "ga" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-easy-align"
  },
  ["vim-external"] = {
    config = { "require('plugin.vim_external')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-external"
  },
  ["vim-fugitive"] = {
    config = { "require('plugin.fugitive')" },
    keys = { { "n", "gs" }, { "n", "<Leader>gp" } },
    loaded = false,
    needs_bufread = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-fugitive"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-startify"
  }
}

-- Config for: vim-external
require('plugin.vim_external')
-- Config for: gruvbox.nvim
require('plugin.colorscheme')
-- Config for: indentLine
require('plugin.indentline')

-- Command lazy-loads
vim.cmd [[command! -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'startuptime.vim'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file TSPlaygroundToggle lua require("packer.load")({'playground'}, { cmd = "TSPlaygroundToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]

-- Keymap lazy-loads
vim.cmd [[nnoremap <silent> <C-f> <cmd>lua require("packer.load")({'nvim-tree.lua'}, { keys = "<lt>C-f>", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ga", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <C-n> <cmd>lua require("packer.load")({'nvim-tree.lua'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>gp <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>Leader>gp", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[noremap <silent> / <cmd>lua require("packer.load")({'vim-cool'}, { keys = "/", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ga", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> gs <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[noremap <silent> ? <cmd>lua require("packer.load")({'vim-cool'}, { keys = "?", prefix = "" }, _G.packer_plugins)<cr>]]

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-treesitter'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd("augroup END")
END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
