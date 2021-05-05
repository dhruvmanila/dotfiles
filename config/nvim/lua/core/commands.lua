local cmd = vim.cmd

cmd [[command! Hi :call utils#highlight_groups()]]
cmd [[command! TrimTrailingWhitespace :call utils#trim_trailing_whitespace()]]
cmd [[command! TrimTrailingLines :call utils#trim_trailing_lines()]]
