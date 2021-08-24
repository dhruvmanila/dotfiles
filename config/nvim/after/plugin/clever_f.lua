local g = vim.g

-- Search target character only in the cursor line.
g.clever_f_across_no_line = 1

-- Direction of keys are fixed, 'f' and 'F' always goes forward and backward
-- respectively.
g.clever_f_fix_key_direction = 1

-- Show a prompt when a character is input to search
g.clever_f_show_prompt = 1

-- Similar to `smartcase`.
g.clever_f_smart_case = 1
