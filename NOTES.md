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

### LSP

LSP Config:

Each language config has its properties which can be changed in the setup
function. They are defined here: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md

To change how the diagnostics are displayed in the buffer, refer `lsp-handler-configuration`.
Here's an example to disable virtual text or can even change the spacing between the
virtual text (https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua#L959):

```lua
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {virtual_text = false}
)
```

For triggering document highlight:
```lua
if client.resolved_capabilities.document_highlight == true then
  cmd('augroup lsp_aucmds')
  cmd('au CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
  cmd('au CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
  cmd('augroup END')
end
```

Get count for a particular severity, useful in the statusline.
https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua#L416

If we want line diagnostics by a popup menu instead of virtual text:
https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua#L1102:


#### Adding VSCode like icons to the completion menu:

Steps taken to make it work on MacOS iTerm2:
1. Download the codicons.ttf file
2. Download the font-patcher script along with its dependencies which
   includes the nerd-fonts/src/ directory and the fontforge binary.
3. Download the fontforge binary: `brew install --formula fontforge`
4. Run the following command:

   `fontforge -script font-patcher --complete --custom codicon.ttf --output ~/Library/Fonts --progressbars <font>`

   where, the custom glyph file should be copied to src/glyph directory
   and the appropriate font should be chosen from src/unpatched-fonts/ directory.

5. Copy the generated font to ~/Library/Fonts directory.
6. Set the 'non-ascii font' in iTerm2 preferences to the generated font.
7. Reload the terminal.

Ref:
* vscode-codicons: https://github.com/microsoft/vscode-codicons
* vscode-icons: https://code.visualstudio.com/api/references/icons-in-labels
* nerd-fonts: https://github.com/ryanoasis/nerd-fonts
* font-patcher: https://github.com/ryanoasis/nerd-fonts/blob/master/font-patcher
* fontforge: https://github.com/fontforge/fontforge
* Inspiration: https://github.com/onsails/lspkind-nvim/issues/6
* Alternative: https://github.com/yamatsum/nvim-nonicons
