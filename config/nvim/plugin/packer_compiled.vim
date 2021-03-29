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
  ["galaxyline.nvim"] = {
    config = { "require('plugin.statusline')" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/galaxyline.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plugin.gitsigns')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim"
  },
  ["gruvbox-material"] = {
    after = { "galaxyline.nvim" },
    only_config = true
  },
  ["indent-blankline.nvim"] = {
    config = { "require('plugin.indentline')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim"
  },
  ["nvim-colorizer.lua"] = {
    commands = { "ColorizerToggle" },
    config = { "require('colorizer').setup()" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua"
  },
  ["nvim-compe"] = {
    after_files = { "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_buffer.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_calc.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_emoji.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_nvim_lsp.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_nvim_lua.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_omni.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_path.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_snippets_nvim.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_spell.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_tags.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_treesitter.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_ultisnips.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_vim_lsc.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_vim_lsp.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_vsnip.vim" },
    config = { "require('plugin.completion')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lightbulb"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-lightbulb"
  },
  ["nvim-lspconfig"] = {
    config = { "require('plugin.lspconfig')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
  },
  ["nvim-lua-guide"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-lua-guide"
  },
  ["nvim-nonicons"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-nonicons"
  },
  ["nvim-tree.lua"] = {
    config = { "require('plugin.nvim_tree')" },
    keys = { { "n", "<C-n>" } },
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
    config = { "vim.g.override_nvim_web_devicons = false" },
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
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["startuptime.vim"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/startuptime.vim"
  },
  ["telescope-fzy-native.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/telescope-fzy-native.nvim"
  },
  ["telescope.nvim"] = {
    config = { "require('plugin.telescope')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-cool"] = {
    config = { "vim.g.CoolTotalMatches = 1" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-cool"
  },
  ["vim-dirvish"] = {
    config = { "require('plugin.dirvish')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-dirvish"
  },
  ["vim-dirvish-dovish"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-dirvish-dovish"
  },
  ["vim-easy-align"] = {
    config = { "require('plugin.easy_align')" },
    keys = { { "n", "ge" }, { "x", "ge" } },
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
    config = { "require('plugin.startify')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-startify"
  }
}

-- Config for: gruvbox-material
require('plugin.colorscheme')
-- Config for: vim-startify
require('plugin.startify')
-- Config for: indent-blankline.nvim
require('plugin.indentline')
-- Config for: vim-external
require('plugin.vim_external')
-- Config for: nvim-web-devicons
vim.g.override_nvim_web_devicons = false
-- Config for: vim-cool
vim.g.CoolTotalMatches = 1
-- Config for: telescope.nvim
require('plugin.telescope')
-- Config for: vim-dirvish
require('plugin.dirvish')
-- Load plugins in order defined by `after`
vim.cmd [[ packadd galaxyline.nvim ]]

-- Config for: galaxyline.nvim
require('plugin.statusline')


-- Command lazy-loads
vim.cmd [[command! -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'startuptime.vim'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file ColorizerToggle lua require("packer.load")({'nvim-colorizer.lua'}, { cmd = "ColorizerToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file TSPlaygroundToggle lua require("packer.load")({'playground'}, { cmd = "TSPlaygroundToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]

-- Keymap lazy-loads
vim.cmd [[xnoremap <silent> ge <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ge", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>gp <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>Leader>gp", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> ge <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ge", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <C-n> <cmd>lua require("packer.load")({'nvim-tree.lua'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> gs <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]]

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-lspconfig'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'gitsigns.nvim', 'nvim-treesitter'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd("augroup END")
END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
