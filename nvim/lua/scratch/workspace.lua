local ws = require 'workspace'
local state_mod = require 'workspace.state'
vim.print(state_mod)

local state = state_mod.get_state()
vim.print(state)

local tab_name = 'terminal'
local tab_data = state_mod.get_tab(tab_name)
print(tab_data)
vim.print(tab_data)

ws.open('terminal', 'tab')
