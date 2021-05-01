local function get_last_session_name()
  local session_dir = vim.fn["startify#get_session_path"]()
  local last_session_path = vim.fn.resolve(session_dir .. "/__LAST__")
  return vim.fn.fnamemodify(last_session_path, ":t")
end

vim.api.nvim_exec([[
function! StartifyEntryFormat()
  return 'entry_path'
endfunction
]], false)

function StartifyCenter(lines)
  local longest_line = 0
  for _, line in ipairs(lines) do
    longest_line = math.max(longest_line, vim.fn.strwidth(line))
  end

  for i = 1, #lines do
    local pad = math.floor((vim.fn.winwidth(0) / 2) - (longest_line / 2))
    lines[i] = string.rep(" ", pad) .. lines[i]
  end
  return lines
end


