local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
  execute 'packadd packer.nvim'
end

return require('packer').startup {
  function(use)
    -- Packer
    use 'wbthomason/packer.nvim'

    -- Color scheme
    use {'sainnhe/gruvbox-material', config = [[require('plugin.colorscheme')]]}
    -- use 'sainnhe/sonokai'

    -- Profiling
    use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}
  end
}
