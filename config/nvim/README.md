# Neovim Configuration

## Overview:

```bash
.
├── after
│   ├── ftplugin             # Override filetype settings
│   │   └── ...
│   └── plugin               # Plugin configurations
│       └── ...
├── colors                   # Custom defined colorschemes
│   └── ...
├── lua
│   ├── dm                   # Lua namespace to avoid clashes
│   │   ├── linters          # Linter configurations
│   │   │   └── ...
│   │   ├── lsp              # Everything LSP
│   │   │   └── ...
│   │   ├── plugins          # For loading plugins using require(...)
│   │   │   └── ...
│   │   ├── themes           # Custom themes
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
├── queries                  # Custom treesitter queries
│   └── ...
├── init.lua
├── filetype.lua             # Help filetype detection
└── minimal.lua              # Minimal bug repro template
```
