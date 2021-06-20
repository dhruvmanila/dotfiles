# Neovim Configuration

### Overview:

```
.
├── after
│   ├── ftplugin               # Override filetype settings
│   │   └── ...
│   ├── queries                # Override treesitter queries
│   │   └── ...
│   └── plugin                 # Plugin configurations
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

### Packer related files:
```
.local/share/nvim/site/pack/loader/start/packer.nvim/plugin/
├── packer_compiled.vim
└── packer_plugin_info.lua
```
