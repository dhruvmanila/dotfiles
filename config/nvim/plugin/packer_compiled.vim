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
  local time
  local profile_info
  local should_profile = true
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time("Luarocks path setup", true)
local package_path_str = "/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time("Luarocks path setup", false)
time("try_loadstring definition", true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

time("try_loadstring definition", false)
time("Defining packer_plugins", true)
_G.packer_plugins = {
  ["FixCursorHold.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/FixCursorHold.nvim"
  },
  ["format.nvim"] = {
    config = { "require('plugin.format')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/format.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plugin.gitsigns')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim"
  },
  ["gruvbox-material"] = {
    config = { "require('plugin.colorscheme')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/gruvbox-material"
  },
  ["indent-blankline.nvim"] = {
    config = { "require('plugin.indentline')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim"
  },
  ["lsp-status.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/lsp-status.nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/lspsaga.nvim"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n¡\1\0\0\6\0\n\0\0146\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\0016\0\a\0'\2\b\0B\0\2\0029\0\t\0B\0\1\1K\0\1\0\nsetup\14colorizer\frequire\1\0\1\fnoremap\2\29<Cmd>ColorizerToggle<CR>\15<Leader>cc\6n\20nvim_set_keymap\bapi\bvim\0" },
    keys = { { "n", "<Leader>cc" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua"
  },
  ["nvim-compe"] = {
    after_files = { "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_buffer.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_calc.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_emoji.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_luasnip.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_nvim_lsp.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_nvim_lua.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_omni.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_path.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_snippets_nvim.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_spell.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_tags.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_treesitter.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_ultisnips.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_vim_lsc.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_vim_lsp.vim", "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe_vsnip.vim" },
    config = { "require('plugin.completion')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lightbulb"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-lightbulb"
  },
  ["nvim-lint"] = {
    config = { "require('plugin.lint')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-lint"
  },
  ["nvim-lspconfig"] = {
    config = { "require('plugin.lspconfig')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
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
    config = { "require('plugin.nvim_web_devicons')" },
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
  ["pylance.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/pylance.nvim"
  },
  ["requirements.txt.vim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/requirements.txt.vim"
  },
  ["startuptime.vim"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/startuptime.vim"
  },
  ["symbols-outline.nvim"] = {
    config = { "\27LJ\2\nt\0\0\6\0\a\0\t6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\1\fnoremap\2\28<Cmd>SymbolsOutline<CR>\15<Leader>so\6n\20nvim_set_keymap\bapi\bvim\0" },
    keys = { { "n", "<Leader>so" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/symbols-outline.nvim"
  },
  ["telescope-arecibo.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/telescope-arecibo.nvim"
  },
  ["telescope-bookmarks.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/telescope-bookmarks.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim"
  },
  ["telescope-fzy-native.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/telescope-fzy-native.nvim"
  },
  ["telescope.nvim"] = {
    config = { "require('plugin.telescope')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["tree-sitter-lua"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/tree-sitter-lua"
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
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-scriptease"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-scriptease"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-startify"
  },
  ["vim-toml"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-toml"
  },
  ["vista.vim"] = {
    config = { "require('plugin.vista')" },
    keys = { { "n", "<Leader>vv" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vista.vim"
  }
}

time("Defining packer_plugins", false)
-- Setup for: symbols-outline.nvim
time("Setup for symbols-outline.nvim", true)
require('plugin.symbols_outline')
time("Setup for symbols-outline.nvim", false)
-- Config for: vim-external
time("Config for vim-external", true)
require('plugin.vim_external')
time("Config for vim-external", false)
-- Config for: vim-dirvish
time("Config for vim-dirvish", true)
require('plugin.dirvish')
time("Config for vim-dirvish", false)
-- Config for: gruvbox-material
time("Config for gruvbox-material", true)
require('plugin.colorscheme')
time("Config for gruvbox-material", false)
-- Config for: vim-cool
time("Config for vim-cool", true)
vim.g.CoolTotalMatches = 1
time("Config for vim-cool", false)
-- Config for: nvim-web-devicons
time("Config for nvim-web-devicons", true)
require('plugin.nvim_web_devicons')
time("Config for nvim-web-devicons", false)
-- Config for: vim-fugitive
time("Config for vim-fugitive", true)
require('plugin.fugitive')
time("Config for vim-fugitive", false)

-- Command lazy-loads
time("Defining lazy-load commands", true)
vim.cmd [[command! -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'startuptime.vim'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file TSPlaygroundToggle lua require("packer.load")({'playground'}, { cmd = "TSPlaygroundToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
time("Defining lazy-load commands", false)

-- Keymap lazy-loads
time("Defining lazy-load keymaps", true)
vim.cmd [[xnoremap <silent> ge <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ge", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>vv <cmd>lua require("packer.load")({'vista.vim'}, { keys = "<lt>Leader>vv", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>cc <cmd>lua require("packer.load")({'nvim-colorizer.lua'}, { keys = "<lt>Leader>cc", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> ge <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ge", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <C-n> <cmd>lua require("packer.load")({'nvim-tree.lua'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>so <cmd>lua require("packer.load")({'symbols-outline.nvim'}, { keys = "<lt>Leader>so", prefix = "" }, _G.packer_plugins)<cr>]]
time("Defining lazy-load keymaps", false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Event lazy-loads
time("Defining lazy-load event autocommands", true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-treesitter', 'indent-blankline.nvim'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'nvim-treesitter', 'gitsigns.nvim', 'indent-blankline.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-lspconfig', 'gitsigns.nvim'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
time("Defining lazy-load event autocommands", false)
vim.cmd("augroup END")
if should_profile then save_profiles(0) end

END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
