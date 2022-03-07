# Neovim Configuration

### Overview:

```bash
.
├── after
│   ├── ftplugin             # Override filetype settings
│   │   └── ...
│   ├── queries              # Override treesitter queries
│   │   └── ...
│   └── plugin               # Plugin configurations
│       └── ...
├── colors                   # Custom defined colorschemes
│   └── ...
├── lua
│   ├── dm                   # Lua namespace to avoid clashes
│   │   ├── formatter        # Custom formatter setup
│   │   │   └── ...
│   │   ├── linter           # Custom linter setup
│   │   │   └── ...
│   │   ├── lsp              # Everything LSP
│   │   │   └── ...
│   │   ├── plugins          # For loading plugins using require(...)
│   │   │   └── ...
│   │   ├── globals.lua      # Globals such as 'dm' namespace
│   │   └── *.lua ...        # Lua utilities and more
│   └── telescope
│       └── _extensions
│           └── ...          # Custom telescope extensions
├── plugin
│   ├── mine                 # setup files for custom plugins
│   │   └── ...
│   ├── *.vim ...            # First all .vim files are loaded
│   └── *.lua ...            # And then all .lua files are loaded
├── init.lua
├── filetype.lua             # Help filetype detection
└── minimal.lua              # Minimal bug repro template
```

### Packer related files:

```bash
.local/share/nvim/site/pack/loader/start/meta/plugin/
├── packer_compiled.lua
└── packer_plugin_info.lua   # For `:Telescope installed_plugins`
```
