---@meta
error 'Cannot require a meta file'

---@generic T
---@param items T[]
---@param opts { prompt: string|nil, format_item: (fun(item: T):string), kind: string|nil }
---@param on_choice fun(item: T|nil, idx: integer|nil)
function vim.ui.select(items, opts, on_choice) end

---@overload fun(cmd: string[], on_exit?: fun(result: vim.SystemCompleted))
---@overload fun(cmd: string[], opts?: vim.SystemOpts, on_exit?: fun(result: vim.SystemCompleted))
function vim.system(cmd, opts, on_exit) end

---@class DashboardEntry
---@field key string keymap to trigger the `command`
---@field description string|fun():string oneline command description
---@field command string|function execute the string/function on `key`

---@class GitHubStar
---@field name string
---@field description string
---@field url string

---@class LinterConfig
---@field cmd string
---@field args? string[]|fun(bufnr: number):string[]
---@field enable? fun(bufnr: number):boolean?
---@field stdin? boolean (default: false)
---@field stream? '"stdout"'|'"stderr"' (default: "stdout")
---@field ignore_exitcode? boolean (default: false)
---@field env? table<string, string>
---@field parser fun(output: string, bufnr: number): table

---@class Session
---@field branch? string
---@field name string
---@field path string
---@field project string

---@class Tabpage
---@field index integer
---@field name string
---@field flags string
---@field is_active boolean

---@class Text
---@field bufnr number
---@field longest_line number
---@field line number
---@field current string
---@field linehl TextHighlight[]

---@class TextHighlight
---@field hl_group string
---@field from number
---@field to number

-- Rust analyzer type definitions for client side extensions.
-- See: https://github.com/rust-lang/rust-analyzer/blob/master/crates/rust-analyzer/src/lsp/ext.rs

---@class CargoRunnable
---@field label string
---@field kind 'cargo'
---@field args CargoRunnableArgs

---@class CargoRunnableArgs
---@field cargoArgs string[]
---@field executableArgs string[]
---@field cwd string
---@field workspaceRoot? string
---@field environment? table<string, string>

---@class ExpandedMacro
---@field name string
---@field expansion string

---@class ExternalDocsResponse
---@field web? string
---@field local? string
