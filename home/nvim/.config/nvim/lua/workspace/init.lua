local M = {}

_G.W = M

local state = require 'workspace.state'
local tabs = require 'workspace.tabs'
local windows = require 'workspace.windows'

function M.setup()
  state.initialize()
  tabs.initialize()
  windows.initialize()

  vim.keymap.set({ 'n', 't' }, '<C-M-j>', function()
    windows.open_window 'code'
  end, { desc = 'Open code window' })
  vim.keymap.set({ 'n', 't' }, '<C-M-k>', function()
    windows.open_window 'tools'
  end, { desc = 'Open tools window' })
  vim.keymap.set({ 'n', 't' }, '<C-M-l>', function()
    windows.open_window 'terminal'
  end, { desc = 'Open terminal window' })
end

function M.default_workspace()
  Snacks.explorer.open()
  -- Delay this to allow the explorer to open first
  vim.defer_fn(function()
    windows.open_window 'code'
  end, 50)
end

function M.debug()
  print(vim.inspect(state.get()))
end

M.tabs = tabs
M.windows = windows

M.setup()

-- vim.api.nvim_create_autocmd({ 'WinNew', 'WinClosed' }, {
--   callback = function(ev)
--     print(string.format('Event fired: %s', vim.inspect(ev)))
--     local info = debug.getinfo(2, 'S')
--     print(string.format('Info: %s', vim.inspect(info)))
--   end,
-- })

return M
