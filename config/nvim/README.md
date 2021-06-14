# Neovim Configuration

### Proposed Neovim config structure

With the merge of the PR (https://github.com/neovim/neovim/pull/14686), we can
now add `.lua` files in runtime paths and they will be sourced by Neovim. So,
this is me brainstorming about my config structure:

```
.
├── after
│   ├── ftplugin               # Override filetype settings
│   │   └── ...
│   ├── queries                # Override treesitter queries
│   │   └── ...
│   └── plugin                 # Plugins configuration
│       └── ...
├── ftdetect                   # Help filetype detection
│   └── ...
├── lua
│   ├── dm                     # Lua namespace to avoid clashes
│   │   ├── globals            # It is imperative that globals are loaded first
│   │   │   └── ...
│   │   ├── formatter          # Custom formatter setup
│   │   │   └── ...
│   │   ├── lsp                # Everything LSP
│   │   │   └── ...
│   │   ├── plugin             # For loading plugins using require(...)
│   │   │   └── ...
│   │   └── *.lua ...          # Lua utilities and more
│   └── telescope
│       └── _extensions
│           └── ...            # Custom telescope extensions
├── plugin
│   ├── *.vim ...              # First all .vim files are loaded
│   ├── *.lua ...              # And then all .lua files are loaded
│   └── packer_compiled.vim
├── cheat40.txt
├── init.lua                   # Global vars and require globals module
└── minimal.vim
```

### TODO:

- [ ] Update to `vim.opt`. Refer `:h vim.opt`
