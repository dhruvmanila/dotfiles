# Notes

## Neovim

* Github: https://github.com/neovim/neovim
* Help: https://github.com/nanotee/nvim-lua-guide

### init.lua

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

#### Telescope browser bookmarks plugin

I have a script (thanks to @junegunn) which can fzf over my Brave bookmarks, but
for that I have to be in a terminal. With the advent of telescope, I have the
tools necessary to create a small extension to do the same thing directly from
Neovim using telescope and so I did :)

Now, I have decided to convert that into a plugin for other people as well.
This will be my notes regarding the process into what sort of information is
required and how to use the telescope API to create such an extension with
user configuration options.

**First step: Each browser has its own file where it stores the bookmarks in
some format like JSON**

- Safari: ~/Library/Safari/Bookmarks.plist (out of option lol)
- Firefox: only stores backup in a non-parsable JSON format :(

- Chrome (mac): ~/Library/Application Support/Google/Chrome/Default/Bookmarks
- Chrome (unix): ~/.config/google-chrome/Default/Bookmarks OR ~/.config/chromium/Default/Bookmarks
- Chrome (win):
- Brave (mac): ~/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks
- Brave (unix):
- Brave (win):

_Chrome and Brave have the same location as Brave uses Chromium_

_Supported filetypes: Brave and Chrome JSON specification_

_Option: Can we just have the location from the user as an option? We could then
verify whether we can parse that fileformat_

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
