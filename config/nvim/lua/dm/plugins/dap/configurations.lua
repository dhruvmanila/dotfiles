local dap = require 'dap'

-- Return the path to Python executable.
---@return string
local function get_python_path()
  -- Use activated virtual environment.
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. '/bin/python'
  end
  -- Fallback to global pyenv Python.
  return vim.fn.exepath 'python'
end

-- Enable debugger logging if Neovim is opened in debug mode. To open Neovim
-- in debug mode, use the environment variable `DEBUG` like: `$ DEBUG=1 nvim`.
---@return boolean?
local function log_to_file()
  if vim.env.DEBUG then
    -- https://github.com/microsoft/debugpy/wiki/Enable-debugger-logs
    vim.env.DEBUGPY_LOG_DIR = vim.fn.stdpath 'cache' .. '/debugpy'
    return true
  end
end

---@see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
dap.configurations.python = {
  {
    name = 'Launch: file',
    type = 'python',
    request = 'launch',
    program = '${file}',
    console = 'internalConsole',
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
  },
  {
    name = 'Launch: file with arguments',
    type = 'python',
    request = 'launch',
    program = '${file}',
    args = function()
      local args = vim.fn.input 'Arguments: '
      return vim.split(args, ' +', { trimempty = true })
    end,
    console = 'internalConsole',
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
  },
  {
    name = 'Launch: module',
    type = 'python',
    request = 'launch',
    module = '${relativeFileDirname}',
    cwd = '${workspaceFolder}',
    console = 'internalConsole',
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
  },
  {
    name = 'Launch: module with arguments',
    type = 'python',
    request = 'launch',
    module = '${relativeFileDirname}',
    cwd = '${workspaceFolder}',
    args = function()
      local args = vim.fn.input 'Arguments: '
      return vim.split(args, ' +', { trimempty = true })
    end,
    console = 'internalConsole',
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
  },
  {
    type = 'python',
    request = 'attach',
    name = 'Attach: remote',
    console = 'internalConsole',
    justMyCode = false,
    pythonPath = get_python_path,
    logToFile = log_to_file,
    host = function()
      local value = vim.fn.input 'Host [127.0.0.1]: '
      if value ~= '' then
        return value
      end
      return '127.0.0.1'
    end,
    port = function()
      return tonumber(vim.fn.input 'Port [5678]: ') or 5678
    end,
  },
}

-- Return a table of options for debugging a advent of code solution.
--
-- The year and day is parsed from the filename. The format of filename should
-- be `.../year<YYYY>/sol<DD>...` where the day should be zero padded. The
-- format of the options will be `{ "-y", "YYYY", "-d", "DD" }` with an
-- optional `-t` flag if the user wants to use the test input.
---@return string[]
local function get_advent_of_code_args()
  local bufname = vim.api.nvim_buf_get_name(0)
  local year, day = bufname:match '.*year(%d+)/sol(%d+)'
  if year == nil or day == nil then
    dm.notify(
      'Debug Advent of Code solution',
      'Unable to determine year/day for: ' .. bufname,
      4
    )
    return {}
  end
  day = day:gsub('^0', '')
  local args = { '-y', year, '-d', day }
  if
    vim.fn.confirm(('Use test input for %s/%s?'):format(year, day), '&Yes\n&No')
    == 1
  then
    table.insert(args, '-t')
  end
  return args
end

---@see https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
dap.configurations.c = {
  {
    name = 'Launch: file',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input(
        'Path to executable: ',
        vim.fn.getcwd() .. '/',
        'file'
      )
    end,
    cwd = '${workspaceFolder}',
  },
  {
    name = 'Build and Launch: AOC solution',
    type = 'lldb',
    request = 'launch',
    program = function()
      -- Build the `aoc` executable with debug symbols.
      vim.cmd '!make --always-make DEBUG=1'
      return vim.loop.cwd() .. '/aoc'
    end,
    cwd = '${workspaceFolder}',
    args = get_advent_of_code_args,
  },
}

---@see https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = 'go',
    name = 'Launch: file',
    request = 'launch',
    mode = function()
      return vim.endswith(vim.api.nvim_buf_get_name(0), '_test.go') and 'test'
        or 'debug'
    end,
    program = '${file}',
  },
  {
    type = 'go',
    name = 'Launch: Advent of Code solution',
    request = 'launch',
    mode = 'debug',
    program = '${workspaceFolder}',
    args = get_advent_of_code_args,
  },
}
