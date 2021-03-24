-- Ref: https://github.com/junegunn/vim-easy-align
local map = require('core.utils').map

map({'n', 'x'}, 'ge', '<Plug>(EasyAlign)', {noremap = false, silent = true})
