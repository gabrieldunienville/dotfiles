local M = {}

local tabs = require 'workspace.tabs'
local state = require 'workspace.state'

function M.setup()
  state.initialize()
  tabs.initialize()

  vim.keymap.set('n', '<leader>wm', function()
    tabs.open_tab 'main'
  end, { desc = 'Open main tab' })

  vim.keymap.set('n', '<leader>wt', function()
    tabs.open_tab 'terminal'
  end, { desc = 'Open terminal tab' })

  vim.keymap.set('t', '<C-e>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
end

-- Auto-setup when module is loaded
M.setup()

return M
