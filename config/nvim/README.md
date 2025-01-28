# Neovim Configuration

This is my personal Neovim configuration. It is not recommended to use this
configuration as is. Instead, you can use it as a reference to build your own
configuration.

## Troubleshooting

The config is equipped with a custom logging system. There are multiple ways to
control the log level for different parts of the configuration. These are:

Environment variables:

- `NVIM_LOG_LEVEL` for the entire configuration
- `NVIM_LSP_LOG_LEVEL` for the LSP specifically

Commands:

- `:SetLogLevel` for the entire configuration
- `:LspSetLogLevel` for the LSP specifically

For any subsystem like the LSP, if the log level for the subsystem is provided,
then it is preferred otherwise the global log level is used. These logs are
available under `vim.fn.stdpath('log')` directory.

Every LSP client has it's own logger and thus it's own log file. These log files
are named as `lsp.<client_name>.log` under the log directory. The log level for
each client is the same as the LSP log level.
