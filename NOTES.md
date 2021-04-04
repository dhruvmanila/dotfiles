# Notes

## Neovim

* Github: https://github.com/neovim/neovim
* Help: https://github.com/nanotee/nvim-lua-guide

### init.lua

`g:vimsyn_embed` allows users to embed script highlighting within vim script.
This is not going to be useful as most things will be in lua but just keeping
it here.

ShaDa (Shared Data) is like viminfo for neovim to persist data across sessions.

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
virtual text (https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/diagnostic.lua#L959)

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
