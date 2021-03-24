# Notes

## Neovim

* Github: https://github.com/neovim/neovim
* Help: https://github.com/nanotee/nvim-lua-guide
* Run :checkhealth

### Python virtual environment

Assigning one virtualenv for Neovim and hard-code the interpreter path via
`g:python3_host_prog` / `g:python_host_prog`. Also, only python3 is going to
be used, so disable python2 with `let g:loaded_python_provider = 0`.

```shell
pyenv install 3.9.1
pyenv virtualenv 3.9.1 neovim3
pyenv activate neovim3
pip install pynvim

# The following is optional, and the neovim3 env is still active
# This allows flake8 to be available to linter plugins regardless
# of what env is currently active.  Repeat this pattern for other
# packages that provide cli programs that are used in Neovim.
pip install black isort mypy flake8

pyenv which python  # path to python, assign it to g:python3_host_prog
pyenv deactivate
```

For help
- :h python-virtualenv
- https://github.com/deoplete-plugins/deoplete-jedi/wiki/Setting-up-Python-for-Neovim
- https://github.com/JJGO/dotfiles/blob/master/shell-setup.sh#L74

### Node provider

_From docs :h provider-nodejs_

Command to start the Node.js host. Setting this makes startup faster.

By default, Nvim searches for "neovim-node-host" using "npm root -g", which
can be slow. To avoid this, set `g:node_host_prog` to the host path: >
    `let g:node_host_prog = '/usr/local/bin/neovim-node-host'`

- https://github.com/JJGO/dotfiles/blob/master/shell-setup.sh#L103

### init.lua

`g:vimsyn_embed` allows users to embed script highlighting within vim script.
This is not going to be useful as most things will be in lua but just keeping
it here.

ShaDa (Shared Data) is like viminfo for neovim to persist data across sessions.

### Options | Variables | Mappings

* Global: `vim.api.nvim_{set|get}_option()`
* Buffer: `vim.api.nvim_buf_{set|get}_option()`
* Window: `vim.api.nvim_win_{set|get}_option()`

Much easier version:
* Global: `vim.o`
* Buffer: `vim.bo`
* Window: `vim.wo`

:h lua-vim-options
:h lua-vim-variables

Mappings: https://github.com/nanotee/nvim-lua-guide#defining-mappings

### Plugins

Neovim will autoload everything in the `.config/nvim/plugin/` directory.

- Plugin manager: https://github.com/wbthomason/packer.nvim
- Comment: https://github.com/terrortylor/nvim-comment

### Config

**Core files will be in the lua/core directory as follows**:
- Plugins: `./lua/core/plugins.lua` (require it)
- Options: `./lua/core/options.lua` (require it)
- Mappings: `./lua/core/mappings.lua`
- Autocmds: `./lua/core/autocmds.lua`
- Commands: `./lua/core/commands.lua`

**Plugin configuration will be in one of the below two directories depending on
whether we are using lua or vim:**
- New style plugins (lua): `./lua/plugin/*.lua`
- Old style plugins (vim): `./after/plugin/*.vim`
_NOTE: Name of the file should configure the plugin with the corresponding name._

All the paths will be specified to `packer.nvim` in the plugin specification
table in the provided `use` function. When https://github.com/neovim/neovim/pull/13823
is merged, it will an easier transition or we can just use
https://github.com/tjdevries/astronauta.nvim but probably not. So, I am sticking
to providing config paths for now.

**Other files:**
- Filetype: `./after/filetype/*.vim`
- Indent: `./after/indent/*.vim`

### Telescope

`find_files` options:
- `find_command` (can provide custom command here)
- `hidden`
- `follow`
- `search_dirs` (search only in these dirs)
- `cwd` (search in this directory)
- `entry_marker` (?)
- `shorten_path` (as the name suggests)
- other config values
