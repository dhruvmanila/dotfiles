local opt_local = vim.opt_local
local nmap = dm.nmap

opt_local.number = false
opt_local.relativenumber = false
opt_local.list = false

local opts = { buffer = true, nowait = true }

nmap("gh", "g?", opts)
nmap("q", "gq", opts)
