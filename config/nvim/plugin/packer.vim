" Lazy packer setup. This mainly defines the keybindings, commands, autocmds,
" path values and the logic to install packer and all the plugins on a fresh
" setup.

let s:pack_path = stdpath("data") . "/site/pack/"
let s:loader_path = s:pack_path . "loader/start/packer.nvim/plugin/"
let s:install_path = s:pack_path . "packer/opt/packer.nvim"

" Setting up the required path globals.
let g:packer_compiled_path = s:loader_path . "packer_compiled.lua"
let g:packer_plugin_info_path = s:loader_path . "packer_plugin_info.lua"

" Install packer and all the plugins automatically on a fresh setup. The
" packer sync function is run synchronously to avoid Neovim from crashing.
"
" I tried different ways to achieve this from which the two main were:
" 1. Put the code in 'dm.plugins' and run it from 'init.lua' but that would
"    error out with: 'Command too recursive'
" 2. Put the code in 'plugin/packer.lua' and that will be sourced automatically
"    by Neovim but it would be after a few other files and thus it would have
"    to be renamed to something like '00-packer.lua' which is just ugly.
"
" So, at the end I settled onto writing it in vim as all vim files are sourced
" before the lua files.
if empty(glob(s:install_path)) > 0
  echo "Installing packer.nvim..."
  exe "!git clone https://github.com/wbthomason/packer.nvim " . s:install_path
  packadd packer.nvim

  let g:packer_complete = 0
  autocmd User PackerComplete ++once let g:packer_complete = 1
  lua require('dm.plugins').sync()

  while !g:packer_complete
    redraw
    sleep 100m
  endwhile

  lua require('dm.plugins').dump()
  echo "Please restart Neovim, quiting in 3 seconds..."
  sleep 3
  quitall!
endif

" Define all the necessary commands similar to packer.nvim
" Don't use `require`, because we really do want to load it fresh before every
" Packer command, otherwise we are stuck with whatever was in that file the
" first time. Another way to do this is using `dofile` but that requires the
" full path name of the file: "stdpath('config') .. '/lua/dm/plugins.lua'"
" Refer: `packer.make_commands`
command! PackerInstall lua R('dm.plugins').install()
command! PackerUpdate lua R('dm.plugins').update()
command! PackerSync lua R('dm.plugins').sync()
command! PackerCompile lua R('dm.plugins').compile()
command! PackerClean lua R('dm.plugins').clean()
command! PackerStatus lua require('dm.plugins').status()
command! PackerProfile lua require('dm.plugins').profile_output()
command! PackerCompiledEdit exe "tabedit " . g:packer_compiled_path

" Dump the plugin information table to a file everytime any of the packer
" commands are completed which includes 'install', 'update', 'sync', 'clean'.
augroup dm__packer_dump
  autocmd!
  autocmd User PackerComplete lua require('dm.plugins').dump()
augroup END

nnoremap <leader>ps <Cmd>PackerSync<CR>
